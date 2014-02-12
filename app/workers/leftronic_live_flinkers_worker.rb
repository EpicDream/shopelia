class LeftronicLiveFlinkersWorker
  include Sidekiq::Worker

  def perform hash
    Leftronic.new.notify_flinkers_count
  end
end