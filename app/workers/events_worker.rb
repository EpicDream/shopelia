class EventsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  def perform hash
    if hash["urls"]
      Event.from_urls(hash)
    elsif hash["ids"]
      Event.from_ids(hash)
    end
  end
end