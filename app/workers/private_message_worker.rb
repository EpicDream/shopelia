require 'flink/notification'

class PrivateMessageWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false

  def perform flinker_id, sender_id, answer=false
    flinker = Flinker.find(flinker_id)
    sender = Flinker.find(sender_id)
    if answer
      Flink::PrivateMessageAnswerNotification.new(flinker, sender).deliver
    else
      Flink::PrivateMessageNotification.new(flinker, sender).deliver
    end
  end
end
