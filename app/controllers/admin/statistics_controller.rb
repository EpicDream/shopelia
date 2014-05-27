class Admin::StatisticsController < Admin::AdminController
  
  def index
    @statistics = Statistic.new.of_publishers
    @statistics_for_day = Statistic.new(from:params[:from_date]).of_publishers
    @likes = Statistic.top_liked_looks_for_day(Time.now - 1.week, Time.now, 20)
    @top_active = Statistic.top_active_flinkers(Time.now - 1.week, Time.now, 100).with_location
  end
  
end
