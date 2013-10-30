class Api::V1::CollectionsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_scope
  before_filter :retrieve_tags, :only => :index
  before_filter :retrieve_collections, :only => :index
  before_filter :retrieve_collection, :only => :show

  api :GET, "/collections", "Get all collections by tags"
  def index
    render json: ActiveModel::ArraySerializer.new(@collections)
  end

  api :GET, "/collections/:uuid", "Get collection's product"
  def show
    render json: ActiveModel::ArraySerializer.new(@collection.products.available, scope:@scope)
  end

  private

  def retrieve_tags
    @tags = Tag.where(name:params[:tags] || [])
  end

  def retrieve_collections
    @collections = @tags.map{|tag| tag.collections}.inject(:&) || []
  end

  def retrieve_collection
    @collection = Collection.find_by_uuid(params[:id])
  end

  def prepare_scope
    @scope = { developer:@developer, short:true }
  end
end