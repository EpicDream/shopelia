require 'nexmo'

class NexmoGateway

  def initialize
    @nexmo = Nexmo::Client.new('00dadf0d', '9d7715e2')
  end

  def send_sms phone_number, text
    if Rails.env.test?
      $sms_gateway_count += 1
    else
      @nexmo.send_message({:to => phone_number , :from => 'Shopelia', :text => text})
    end
  end
end