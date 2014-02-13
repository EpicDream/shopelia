class LeftronicLiveFlinkersWorker
  include Sidekiq::Worker

  def perform
    Leftronic.new.notify_flinkers_count
  end
end