module Flink
  module Push

    def self.deliver message, device, metadata={}
      return if device.nil? || device.push_token.nil?
      config = Rails.application.config.apns[device.env]
      [:host, :port, :pem, :pass].each { |key| APNS.send("#{key}=", config[key]) }
      
      APNS.send_notification(
        device.push_token, 
        alert: message.first(150), 
        :"content-available" => 1, 
        sound: 'default', 
        other: { metadata: metadata }
      )
    end

  end
end