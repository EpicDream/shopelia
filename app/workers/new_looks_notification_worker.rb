require 'flink/notification'

class NewLooksNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false

  def perform flinkers_ids, publisher_id
    publisher = Flinker.find(publisher_id)
    
    Flinker.where(id:flinkers_ids).find_in_batches { |flinkers|
      flinkers.each { |flinker| Flink::NewLooksNotification.new(flinker, publisher).deliver }
    }
  end
end