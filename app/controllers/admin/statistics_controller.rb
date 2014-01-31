class Admin::StatisticsController < Admin::AdminController
  
  def index
    @statistics = Statistic.new.of_publishers
    @statistics_for_day = Statistic.new(from:params[:from_date], to:params[:to_date]).of_publishers
  end
  
end
