module Viking

  def self.touch
    Nest.new("viking")[:updated_at].set(Time.now.to_i)
  end

  def self.saturn_alive?
    return true if Product.where("viking_sent_at > ?", 3.minutes.ago).count == 0

    delay_since_updated = Time.now.to_i - Nest.new("viking")[:updated_at].get.to_i
    delay_since_updated < 120
  end
end