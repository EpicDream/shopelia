class Api::Flink::TrendSettersController < Api::Flink::BaseController
  
  def index
    render unauthorized and return unless current_flinker
    render json: { flinkers: flinkers }
  end
  
  private
  
  def flinkers
    Flinker.trend_setters(current_flinker.country)
  end
  
end