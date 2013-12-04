class Api::Flink::LooksController < Api::ApiController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_looks, :only => :index
  before_filter :prepare_scope
  
  api :GET, "/looks", "Get looks"
  def index
    render json: ActiveModel::ArraySerializer.new(@looks, scope:@scope)
  end

  private

  def retrieve_looks
    @looks = Look.where(is_published:true).order("created_at desc")
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, short:true }
  end
end