class Api::Flink::LooksController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  before_filter :retrieve_looks, :only => :index
  
  api :GET, "/looks", "Get looks"
  def index
    render json: {
      published_before: @before,
      published_after: @after,
      per_page: @per_page,
      looks: ActiveModel::ArraySerializer.new(@looks, scope:scope())
    }
  end

  private
  # TODO:Refactoring ; move to Look model
  def retrieve_looks
    if params[:liked]
      render json: {}, status: :unauthorized and return if current_flinker.nil?
      ids = current_flinker.flinker_likes.where(resource_type:FlinkerLike::LOOK).map(&:resource_id)
      @looks = Look.where(id:ids, is_published:true).order("published_at desc")
    elsif !params[:updated_after].blank?
      flinker_ids = current_flinker.flinker_follows.map(&:follow_id) if current_flinker.present?
      query = Look.where(is_published:true)
      query = query.where(flinker_id:flinker_ids) if (flinker_ids || []).any?
      @per_page = params[:per_page] || 10
      @looks = query.published_updated_after(Time.at(params[:updated_after].to_i)).limit(@per_page)
    else
      @before = Time.at(params[:published_before].to_i) unless params[:published_before].blank?
      @after = Time.at(params[:published_after].to_i) unless params[:published_after].blank?
      @per_page = params[:per_page] || 10

      flinker_ids = params[:flinker_ids] || current_flinker.flinker_follows.map(&:follow_id) if current_flinker.present?

      query = Look.where(is_published:true)
      query = query.where(flinker_id:flinker_ids) if (flinker_ids || []).any?
      query = query.where("published_at < ?", @before) if @before.present?
      query = query.where("published_at > ?", @after) if @after.present?
      @looks = query.order("published_at desc").limit(@per_page)
    end
  end

  def scope
    { developer:@developer, device:@device, flinker:current_flinker, short:true }
  end
end