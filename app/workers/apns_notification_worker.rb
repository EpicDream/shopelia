class ApnsNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false
  
  def perform apns_notification_id
    notification = ApnsNotification.find(apns_notification_id)
    notification.send_to_all_flinkers
  end
end
