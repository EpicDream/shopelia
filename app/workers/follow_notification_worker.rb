require 'flink/notification'

class FollowNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false
  
  def perform flinker_id, follower_id
    flinker, follower = [flinker_id, follower_id].map { |id| Flinker.find(id)}
    Flink::FollowNotification.new(flinker, follower).deliver
  end
end
