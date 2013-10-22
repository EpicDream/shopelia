module Viking

  def self.touch_request
    Nest.new("viking")[:created_at].set(Time.now.to_i)
  end

  def self.touch_reply
    Nest.new("viking")[:updated_at].set(Time.now.to_i)
  end

  def self.saturn_alive?
    created_at = Nest.new("viking")[:created_at].get.to_i
    updated_at = Nest.new("viking")[:updated_at].get.to_i
    now = Time.now.to_i

    if created_at > now - 120
      updated_at > now - 60
    else
      true
    end
  end
end