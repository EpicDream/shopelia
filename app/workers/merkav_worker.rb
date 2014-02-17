class MerkavWorker
  include Sidekiq::Worker

  def perform hash
  end
end
