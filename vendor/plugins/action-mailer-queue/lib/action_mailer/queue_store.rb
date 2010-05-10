module ActionMailer
  class Queue < ActionMailer::Base
    class Store < ActiveRecord::Base
    
      named_scope :for_send, :conditions => [ "sent = ?", false]
      named_scope :already_sent, :conditions => [ "sent = ?", true]

      named_scope :with_processing_rules, lambda {{
        :conditions => [ "attempts < ? AND (last_attempt_at < ? OR last_attempt_at IS NULL)", ActionMailer::Queue.max_attempts_in_process, Time.now - ActionMailer::Queue.delay_between_attempts_in_process.minutes], 
        :limit => ActionMailer::Queue.limit_for_processing,
        :order => "priority asc, last_attempt_at asc"
      }}
      named_scope :with_error, :conditions => ["attempts > ?", 0]
      named_scope :without_error, :conditions => ["attempts = ?", 0]
    
      class MailAlreadySent < StandardError; end
      class MailSendingInProgress < StandardError; end
    
      def self.create_by_table_name(table_name)
        self.set_table_name table_name
        return self
      end
    
      def self.process!(options = {})
        self.for_send.with_processing_rules(:all, options.merge(:select => :id)).each { |q| self.find(q.id).deliver! }
      end
    
      def tmail=(mail)
        self.to = mail.to.uniq.join(",") unless mail.to.blank?
        self.from = mail.from.uniq.join(",") unless mail.from.blank?
        self.subject = mail.subject unless mail.subject.blank?
        self.content = mail.encoded
      end
    
      def to_tmail
        tmail = TMail::Mail.parse(self.content)
        tmail.to = self.to.split(",") unless self.to.blank?
        tmail.from = self.from.split(",") unless self.from.blank?
        tmail.subject = self.subject unless self.subject.blank?
        return tmail
      end
    
      def resend!
        self.sent = false
        self.save
        self.deliver!
      end
    
      def deliver!
        raise MailAlreadySent if self.sent == true
        raise MailSendingInProgress if self.in_progress == true
        self.update_attribute(:in_progress, true)
        mail = Mailer.deliver(self.to_tmail)
        if ActionMailer::Queue.destroy_message_after_deliver
          self.destroy
        else
          self.message_id = mail.message_id
          self.sent = true
          self.in_progress = false
          self.sent_at = Time.now
          self.save
        end
        return mail
      rescue => err
        raise err if [ActionMailer::Queue::Store::MailAlreadySent, ActionMailer::Queue::Store::MailSendingInProgress].include?(err.class)
        self.in_progress = false
        self.attempts += 1
        self.last_error = err.to_s
        self.last_attempt_at = Time.now
        self.save
        return false
      end
    
    end
  end  
end