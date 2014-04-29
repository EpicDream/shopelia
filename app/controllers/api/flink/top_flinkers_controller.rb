class Api::Flink::TopFlinkersController < Api::Flink::BaseController
  
  def index
    render json: { flinkers: flinkers }
  end
  
  private
  
  def flinkers
    flinkers = Flinker.similar_to(current_flinker)
    ActiveModel::ArraySerializer.new(flinkers)
  end
  
end