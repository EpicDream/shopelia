class Api::Flink::FlinkersController < Api::Flink::BaseController
  before_filter :retrieve_flinkers, :only => :index
  before_filter :prepare_scope
  
  api :GET, "/flinkers", "Get flinkers"
  def index
    render json: {
      flinkers: ActiveModel::ArraySerializer.new(@flinkers, scope:@scope)
    }
  end

  private

  def retrieve_flinkers
    @flinkers = Flinker.where(is_publisher:true)
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, flinker:current_flinker, short:true }
  end
end