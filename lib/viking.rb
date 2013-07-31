module Viking

  def self.saturn_alive?
    event = Event.where("created_at < ?", 1.minute.ago).order("created_at desc").first
    return true if event.product.nil?
    event.product.updated_at > event.created_at || event.product.versions_expires_at.to_i > event.created_at.to_i
  end

end

