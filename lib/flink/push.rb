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
    
    def self.deliver_by_batch message, devices, metadata={}
      devices.find_in_batches do |devices|
        notifications = devices.map do |device|
          next if device.push_token.nil?
          
          APNS::Notification.new(
            device.push_token, 
            :alert => message.first(150),
            :"content-available" => 1, 
            sound: 'default', 
            other: { metadata: metadata }
          )
        end
        begin
          APNS.send_notifications(notifications)
        rescue => e
          Rails.logger.error("[APNS::Push#deliver_by_batch] #{e.inspect}")
          next
        end
      end
    end

  end
end