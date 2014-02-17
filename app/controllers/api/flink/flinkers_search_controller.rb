class Api::Flink::FlinkersSearchController < Api::Flink::BaseController
  
  api :GET, "/flinkers_search", "Get flinkers by username"
  def index
    render json: { flinkers: flinkers() }
  end

  private

  def flinkers
    flinkers = Flinker.with_username_like(params[:username]).paginate(pagination)
    serialize flinkers
  end

end
