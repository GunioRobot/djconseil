class Notification < ActionMailer::Queue
  
  @@delivery_method = :smtp
  
  def contact(options = {})
    from        options[:from] || "contact@djconseil.fr"
    recipients  options[:recipient] || "contact@djconseil.fr"
    subject     "Prise de contact djconseil.fr"
    @options = options
  end
end