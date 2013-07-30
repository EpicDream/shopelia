module Viking

  def self.saturn_alive?
    event = Event.where("created_at < ?", 1.minute.ago).order("created_at desc").first
    event.product.updated_at > event.created_at
  end

end

