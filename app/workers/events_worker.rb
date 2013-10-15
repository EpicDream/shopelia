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
  rescue Exceptions::RejectingEventsException
    # do nothing
  rescue ActiveRecord::RecordInvalid
  rescue ActiveRecord::RecordNotFound
    UrlMatcher.find_by_url(Linker.clean hash["url"]).try(:destroy)
    UrlMatcher.find_by_url(hash["url"]).try(:destroy)
    raise
  end
end
