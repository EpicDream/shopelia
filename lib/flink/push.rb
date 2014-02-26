module Flink
  module Push

    def self.deliver message, device
      config = Rails.application.config.apns[device.env]
      [:host, :port, :pem, :pass].each { |key| APNS.send("#{key}=", config[key]) }
      APNS.send_notification(device.push_token, alert:message.first(150), :"content-available" => 1)
    end

  end
end