class Api::Flink::LooksController < Api::ApiController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_looks, :only => :index
  before_filter :prepare_scope
  
  api :GET, "/looks", "Get looks"
  def index
    render json: {
      page: @page,
      per_page: @per_page,
      total: @looks_total,
      looks: ActiveModel::ArraySerializer.new(@looks, scope:@scope)
    }
  end

  private

  def retrieve_looks
    @page = params[:page] || 1
    @per_page = params[:per_page] || 10
    query = Look.where(is_published:true)
    @looks = query.order("published_at desc").paginate(page:@page, per_page:@per_page)
    @looks_total = query.count
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, short:true }
  end
end