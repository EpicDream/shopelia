require 'flink/push'

class ApnsNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :apns_notifications, retry:false
  
  def perform message, lang
    Rails.logger.info("ApnsNotificationWorker START #{lang}: #{Time.now}")
    
    if lang.to_sym == :fr
      deliver_push(message, Device.frenches)
    else
      deliver_push(message, Device.not_frenches)
    end
    
    Rails.logger.info("ApnsNotificationWorker END #{lang} : #{Time.now}")
  end
  
  private
  
  def deliver_push text, devices
    devices.find_each { |device| 
      begin
        Flink::Push.deliver(text, device)
      rescue
        Rails.logger.error("[APNS_NOTIFICATION_NOT_SENT] #{device.id}")
      end
    }
  end
end
