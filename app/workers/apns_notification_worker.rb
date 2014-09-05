require 'flink/push'

class ApnsNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :apns_notifications, retry:false
  
  def perform message, lang, metadata={}
    if lang.to_sym == :fr
      Flink::Push.deliver_by_batch(message, Device.frenches, metadata)
    else
      Flink::Push.deliver_by_batch(message, Device.not_frenches, metadata)
    end
  end
  
end
