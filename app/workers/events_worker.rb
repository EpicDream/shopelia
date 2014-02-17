class EventsWorker
  include Sidekiq::Worker

  def perform hash
  end

  def create_event hash
  end
end