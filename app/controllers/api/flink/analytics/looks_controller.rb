class Api::Flink::Analytics::LooksController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def show
    look = Look.with_uuid(params[:id]).first
    statistics = Analytic::Look.statistics(look)
    
    render json: statistics
  end
  
end
