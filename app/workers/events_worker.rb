class EventsWorker
  include Sidekiq::Worker
  
  def perform hash
    Event.from_urls(hash)
  end
end
