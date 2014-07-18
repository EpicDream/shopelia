class Api::Flink::Analytics::PublishersController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def index
    publisher = Flinker.find params[:publisher_id]
    statistics = Analytic::Publisher.statistics(publisher)
    
    render json: statistics
  end
  
end
