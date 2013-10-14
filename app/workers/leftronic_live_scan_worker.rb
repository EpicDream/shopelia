class LeftronicLiveScanWorker
  include Sidekiq::Worker

  def perform hash
    Leftronic.new.notify_live_scan(hash[:name], hash[:ean], hash[:image_url])
  end
end