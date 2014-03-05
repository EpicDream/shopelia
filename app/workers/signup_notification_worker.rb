require 'flink/notification'

class SignupNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false
  
  def perform flinker_id, signed_up_id
    flinker, signed_up = [flinker_id, signed_up_id].map { |id| Flinker.find(id)}
    Flink::SignupNotification.new(flinker, signed_up).deliver
  end
  
end
