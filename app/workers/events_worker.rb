class EventsWorker
  include Sidekiq::Worker

  def perform hash
    Event.create!(
      :url => hash["url"],
      :product_id => hash["product_id"],
      :action => hash["action"],
      :developer_id => hash["developer_id"],
      :device_id => hash["device_id"],
      :tracker => hash["tracker"],
      :ip_address => hash["ip_address"])
  end
end