class DailyStats

  attr_accessor :date 
  attr_accessor :rankings

  def initialize(date=Date.yesterday)
    @date = date
    @rankings = []
    @daily = Event.where("created_at >= ? and created_at < ?", @date, @date + 1.day).group(:action).count
    @monthly = Event.where("created_at >= ? and created_at < ?", @date.at_beginning_of_month, @date.at_end_of_month).group(:action).count
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

  def monthly_views
    @monthly[Event::VIEW]
  end
  
  def monthly_clicks
    @monthly[Event::CLICK]
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
    @rankings << top_daily_developers
  end
  
  def top_daily_merchants
    ranking = {}
    ranking[:name] = "Top daily merchants"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:merchants).group("merchants.name").count
    ranking[:data] = to_sorted_array(hash)
    ranking
  end

  def top_daily_developers
    ranking = {}
    ranking[:name] = "Top daily developers"
    hash = Event.where("action=#{Event::VIEW} and events.created_at >= ? and events.created_at < ?", @date, @date + 1.day).joins(:developer).group("developers.name").count
    ranking[:data] = to_sorted_array(hash)
    ranking
  end

  def to_sorted_array hash
    hash.keys.map{ |k| {:key => k,:value => hash[k]}}.sort_by { |k| k[:value] }.reverse
  end

end

