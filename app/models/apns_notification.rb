require 'flink/push'

class ApnsNotification < ActiveRecord::Base
  EMAILS_FOR_TESTING = ["olivierfisch@hotmail.com", "anoiaque@gmail.com"]
  attr_accessible *column_names
  
  def apns_test
    devices = Device.where(flinker_id: Flinker.where(email:EMAILS_FOR_TESTING).map(&:id))
    Flink::Push.deliver_by_batch(text_fr, devices)
    Flink::Push.deliver_by_batch(text_en, devices)
  end
  
  def send_to_all_flinkers
    ApnsNotificationWorker.perform_async(text_fr, :fr)
    ApnsNotificationWorker.perform_async(text_en, :en)
  end
  
end