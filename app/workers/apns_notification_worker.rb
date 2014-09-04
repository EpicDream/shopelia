require 'flink/push'

class ApnsNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :apns_notifications, retry:false
  
  def perform message, lang
    if lang.to_sym == :fr
      deliver_push(message, Device.frenches)
    else
      deliver_push(message, Device.not_frenches)
    end
  end
  
  private
  
  def deliver_push message, devices
    Flink::Push.deliver_by_batch(message, devices)
  end
end
