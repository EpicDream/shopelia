if Rails.env.development?
  require "letter_opener"
  ActionMailer::Base.add_delivery_method :letter_opener, LetterOpener::DeliveryMethod, :location => File.expand_path('../tmp/letter_opener', __FILE__)
  ActionMailer::Base.delivery_method = :letter_opener
end

class MailPreview
  
  def initialize(resource)
    @resource = resource
  end
  
  def send
    Emailer.password_reset(@resource).deliver
  end
  
end