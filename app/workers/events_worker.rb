class EventsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  def perform hash
    Event.from_urls(hash)
  end
end