class Api::Flink::TrendSettersController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def index
    render json: { flinkers: flinkers }
  end
  
  private
  
  def flinkers
    country = current_flinker ? current_flinker.country : Country.where(iso:params[:iso]).first
    Flinker.trend_setters(country)
  end
  
end