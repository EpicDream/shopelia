module Push

  def self.send_message message
    return unless message.device.push_token.present?
    if Rails.env.test?
      $push_delivery_count += 1
    elsif message.device.android?
      GCM.send_notification message.device.push_token, message.as_push
    elsif message.device.ios?
      self.send_ios_notification message
    else
      raise
    end
  end

  def self.send_ios_notification message
    config = message.device.dev? ? Rails.application.config.apns[:development] : Rails.application.config.apns[:production]
    APNS.host = config[:host]
    APNS.port = config[:port]
    APNS.pem  = config[:pem]
    APNS.pass = config[:pass]

    APNS.send_notification(message.push_token, 
      :alert => message.content.first(100), 
      :badge => 1, 
      :sound => 'default', 
      :other => {:message_id => message.id})
  end
end