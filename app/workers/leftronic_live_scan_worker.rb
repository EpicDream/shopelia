class LeftronicLiveScanWorker
  include Sidekiq::Worker

  def perform hash
    Leftronic.new.notify_live_scan(hash["name"], hash["prices_count"].to_s + ' prix', hash["image_url"])
  end
end
