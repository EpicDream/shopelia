class Api::Flink::FlinkersController < Api::Flink::BaseController
  
  api :GET, "/flinkers", "Get flinkers"
  def index
    render json: { flinkers: flinkers() }
  end

  private

  def flinkers
    flinkers = Flinker.with_username_like(params[:username]).paginate(pagination())
    serialize flinkers
  end

end
