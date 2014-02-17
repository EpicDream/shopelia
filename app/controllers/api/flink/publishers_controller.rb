class Api::Flink::PublishersController < Api::Flink::BaseController
  
  def index
    render json: { flinkers: flinkers() }
  end
  
  private
  
  def flinkers
    serialize Flinker.publishers.with_looks.paginate(pagination)
  end
  
end
