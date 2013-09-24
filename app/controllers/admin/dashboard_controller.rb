class Admin::DashboardController < Admin::AdminController

  def index
    date = Date.today
    @stats = {}

    @stats[:button_current_day] = Event.where("created_at >= ? and created_at < ?", date, date + 1.day).group(:action).count
    @stats[:button_current_day_unique] = Event.where("created_at >= ? and created_at < ?", date, date + 1.day).group(:action).count("distinct device_id")

    @stats[:button_current_month] = Event.where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).group(:action).count
    @stats[:button_current_month_unique] = Event.where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).group(:action).count("distinct device_id")

    @stats[:button_last_month] = Event.where("created_at >= ? and created_at < ?", date.at_beginning_of_month - 1.month, date - 1.month + 1.day).group(:action).count
    @stats[:button_last_month_unique] = Event.where("created_at >= ? and created_at < ?", date.at_beginning_of_month - 1.month, date - 1.month + 1.day).group(:action).count("distinct device_id")

    @stats[:button_views_sparklines] = Event.where("created_at >= ? and created_at < ?", 30.days.ago, date + 1.day).where(action:Event::VIEW).order("date(created_at)").count(group:"date(created_at)").values.join(",")
    @stats[:button_clicks_sparklines] = Event.where("created_at >= ? and created_at < ?", 30.days.ago, date + 1.day).where(action:Event::CLICK).order("date(created_at)").count(group:"date(created_at)").values.join(",")

    @stats[:button_click_rate] = sprintf("%.2f", @stats[:button_current_month][Event::CLICK].to_f * 100 / (@stats[:button_current_month][Event::VIEW] || 1)) + "%"
    @stats[:button_unique_click_rate] = sprintf("%.2f", @stats[:button_current_month_unique][Event::CLICK].to_f * 100 / (@stats[:button_current_month_unique][Event::VIEW] || 1)) + "%"

    @stats[:orders] = Order.completed.count
    @stats[:users] = User.where(visitor:false).count
    @stats[:guests] = User.where(visitor:true).count
    @stats[:items] = CartItem.count
    @stats[:developers] = Developer.count

    @chart = Rails.env.development? ? 
      [{"date"=>"July 2013", "view"=>12245, "click"=>916}, {"date"=>"August 2013", "view"=>34902, "click"=>2013}]
      : render_chart
    @dates = [{"date"=>Date.parse("2013-07-01"), "value"=>"July 2013"}, {"date"=>Date.parse("2013-08-01"), "value"=>"August 2013"}] if Rails.env.development?

    @data = []
    @dates.uniq.each do |e|
      date = e['date']
      events = Event.where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).group(:action).count
      @data << {
        month:e['value'],
        views:events[Event::VIEW],
        clicks:events[Event::CLICK],
        users:User.where(visitor:false).where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).count,
        guests:User.where(visitor:true).where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).count,
        follows:CartItem.where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).count,
        orders:Order.completed.where("created_at >= ? and created_at < ?", date.at_beginning_of_month, date.at_end_of_month).count
      }
    end

  end

  private

  def render_chart
    @dates = []
    chart = []
    Event.count(:group => ["date_trunc('month',created_at)",:action]).each do |data|
      d = Date.parse(data[0][0])
      md = "#{Date::MONTHNAMES[d.month]} #{d.year}"
      @dates << { 'date' => d, 'value' => md }
      if data[0][1] == Event::VIEW
        chart << { "date" => md, "view" => data[1] }
      elsif data[0][1] == Event::CLICK
        chart << { "date" => md, "click" => data[1] }
      end
    end
    chart.group_by{|h| h["date"]}.map{|k,v| v.inject(:merge)}
  end

end
