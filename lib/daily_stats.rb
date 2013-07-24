class DailyStats

  attr_accessor :date 
  attr_accessor :rankings

  def initialize(date=Date.yesterday)
    @date = date
    @rankings = []
    @daily = Event.where("created_at >= ? and created_at < ?", @date, @date + 1.day).group(:action).count
    @daily_unique = Event.where("created_at >= ? and created_at < ?", @date, @date + 1.day).group(:action).count("distinct visitor")
    @monthly = Event.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).group(:action).count
    @monthly_unique = Event.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).group(:action).count("distinct visitor")
    prepare_rankings
  end
  
  def daily_active_developers
    Event.where("created_at >= ? and created_at < ?", @date, @date + 1.day).count("distinct developer_id")
  end

  def daily_active_merchants
    Event.where("events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:merchants).count("distinct merchant_id")
  end
  
  def monthly_active_developers
    Event.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).count("distinct developer_id")
  end

  def monthly_active_merchants
    Event.where("events.created_at >= ? and events.created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).joins(:merchants).count("distinct merchant_id")
  end
  
  def daily_views
    @daily[Event::VIEW]
  end
  
  def daily_clicks
    @daily[Event::CLICK]
  end

  def daily_unique_views
    @daily_unique[Event::VIEW]
  end
  
  def daily_unique_clicks
    @daily_unique[Event::CLICK]
  end

  def monthly_views
    @monthly[Event::VIEW]
  end
  
  def monthly_clicks
    @monthly[Event::CLICK]
  end

  def monthly_unique_views
    @monthly_unique[Event::VIEW]
  end
  
  def monthly_unique_clicks
    @monthly_unique[Event::CLICK]
  end
  
  def daily_orders
    Order.completed.where("created_at >= ? and created_at < ?", @date, @date + 1.day).count
  end
  
  def monthly_orders
    Order.completed.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).count
  end

  def daily_signups
    User.where("created_at >= ? and created_at < ?", @date, @date + 1.day).count
  end
  
  def monthly_signups
    User.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).count
  end

  def send_email
    Emailer.admin_daily_report(self).deliver
  end

  private
  
  def prepare_rankings
    @rankings << top_daily_merchants
    @rankings << top_monthly_merchants
    @rankings << top_daily_developers
    @rankings << top_monthly_developers
  end
  
  def top_daily_merchants
    ranking = {}
    ranking[:name] = "Top daily merchants"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:merchants).group("merchants.name").count
    ranking[:data] = to_sorted_array(hash)
    hash = Event.where("action=#{Event::CLICK} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:merchants).group("merchants.name").count
    ranking[:data].each do |rank|
      rank[:clicks] = hash[rank[:name]]
    end
    ranking
  end

  def top_daily_developers
    ranking = {}
    ranking[:name] = "Top daily developers"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:developer).group("developers.name").count
    ranking[:data] = to_sorted_array(hash)
    hash = Event.where("action=#{Event::CLICK} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:developer).group("developers.name").count
    ranking[:data].each do |rank|
      rank[:clicks] = hash[rank[:name]]
    end
    ranking
  end

  def top_monthly_merchants
    ranking = {}
    ranking[:name] = "Top monthly merchants"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).joins(:merchants).group("merchants.name").count
    ranking[:data] = to_sorted_array(hash)
    hash = Event.where("action=#{Event::CLICK} and events.created_at >= ? and events.created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).joins(:merchants).group("merchants.name").count
    ranking[:data].each do |rank|
      rank[:clicks] = hash[rank[:name]]
    end
    ranking
  end

  def top_monthly_developers
    ranking = {}
    ranking[:name] = "Top monthly developers"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).joins(:developer).group("developers.name").count
    ranking[:data] = to_sorted_array(hash)
    hash = Event.where("action=#{Event::CLICK} and events.created_at >= ? and events.created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).joins(:developer).group("developers.name").count
    ranking[:data].each do |rank|
      rank[:clicks] = hash[rank[:name]]
    end
    ranking
  end
  
  def to_sorted_array hash
    hash.keys.map{ |k| {:name => k,:views => hash[k]}}.sort_by { |k| k[:views] }.reverse
  end

end

