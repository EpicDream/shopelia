require 'flink/notification'

class NewLooksNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications, retry:false

  def perform flinkers_ids, look_id
    look = Look.find(look_id)
    
    Flinker.where(id:flinkers_ids).find_in_batches { |flinkers|
      flinkers.each { |flinker| 
        Flink::NewLooksNotification.new(flinker, look).deliver 
      }
    }
  end
end