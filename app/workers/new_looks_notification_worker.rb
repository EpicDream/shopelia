require 'flink/notification'

class NewLooksNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false

  def perform flinker_id, look_id
    look = Look.find(look_id)
    flinker = Flinker.find(flinker_id)
    Flink::NewLooksNotification.new(flinker, look).deliver 
  end
  
end