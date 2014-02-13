class Api::Flink::TopFlinkersController < Api::Flink::BaseController
  
  def index
    render json: { flinkers: flinkers }
  end
  
  private
  
  def flinkers
    flinkers = FlinkerLike.top_likers.map(&:flinker)
    ActiveModel::ArraySerializer.new(flinkers)
  end
  
end