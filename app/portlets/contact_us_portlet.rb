class ContactUsPortlet < Portlet
  render_inline false

  def render
    if request.post?
      %w{from name message}.each do |name|
        @error = !params.include?(name)
        return if @error
      end

      @notification = Notification.deliver_contact!({
        :from => params.delete(:from),
        :name => params.delete(:name),
        :recipient => @recipient,
        :message => params.delete(:message)
      })

      @sent = true
    end
  end
end
