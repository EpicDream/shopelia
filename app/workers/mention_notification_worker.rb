require 'flink/notification'

class MentionNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false
  
  def perform flinker_id, mentionner_id
    flinker, mentionner = [flinker_id, mentionner_id].map { |id| Flinker.find(id)}
    Flink::MentionNotification.new(flinker, mentionner).deliver
  end
  
end
