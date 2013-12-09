class Api::Flink::LooksController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  before_filter :retrieve_looks, :only => :index
  before_filter :prepare_scope
  
  api :GET, "/looks", "Get looks"
  def index
    render json: {
      published_before: @before,
      published_after: @after,
      per_page: @per_page,
      looks: ActiveModel::ArraySerializer.new(@looks, scope:@scope)
    }
  end

  private

  def retrieve_looks
    @before = Time.at(params[:published_before].to_i) unless params[:published_before].blank?
    @after = Time.at(params[:published_after].to_i) unless params[:published_after].blank?
    @per_page = params[:per_page] || 10

    query = Look.where(is_published:true)
    query = query.where("published_at < ?", @before) if @before.present?
    query = query.where("published_at > ?", @after) if @after.present?

    @looks = query.order("published_at desc").limit(@per_page)
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, short:true }
  end
end