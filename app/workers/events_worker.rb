class EventsWorker
  include Sidekiq::Worker

  def perform hash
    create_event hash
  rescue Exceptions::RejectingEventsException
  rescue ActiveRecord::RecordNotUnique
    # do nothing
  rescue ActiveRecord::RecordInvalid
  rescue ActiveRecord::RecordNotFound
    canonizer = UrlCanonizer.new
    canonizer.del(Linker.clean hash["url"])
    canonizer.del(hash["url"])
    create_event hash
  end

  def create_event hash
    return if hash["product_id"].blank? && hash["url"].blank?
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
