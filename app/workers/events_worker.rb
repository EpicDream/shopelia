class EventsWorker
  include Sidekiq::Worker

  def perform hash
    create_event hash
  rescue Exceptions::RejectingEventsException
    # do nothing
  rescue ActiveRecord::RecordInvalid
  rescue ActiveRecord::RecordNotFound
    UrlMatcher.find_by_url(Linker.clean hash["url"]).try(:destroy)
    UrlMatcher.find_by_url(hash["url"]).try(:destroy)
    create_event hash
  end

  def create_event hash
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
