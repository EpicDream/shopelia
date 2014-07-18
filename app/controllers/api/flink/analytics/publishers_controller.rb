class Api::Flink::Analytics::PublishersController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def show
    publisher = Flinker.find params[:id]
    statistics = Analytic::Publisher.statistics(publisher)
    
    render json: statistics
  end
  
end
