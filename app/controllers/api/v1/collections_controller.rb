class Api::V1::CollectionsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_scope
  before_filter :retrieve_tags, :only => :index
  before_filter :retrieve_collections, :only => :index
  before_filter :retrieve_collection, :only => :show

  api :GET, "/collections", "Get all collections by tags"
  def index
    render json: @collections.sort(&:created_at).reverse.map{ |c| CollectionSerializer.new(c, scope:@scope).as_json[:collection] }
  end

  api :GET, "/collections/:uuid", "Get collection's product"
  def show
    render json: @collection.items.map{ |p| ProductSerializer.new(p, scope:@scope).as_json[:product] }
  end

  private

  def retrieve_tags
    @tags = (params[:tags] || []).map{|n| Tag.find_or_create_by_name(n)}
  end

  def retrieve_collections
    @collections = @tags.map{|tag| tag.collections.public}.inject(:&) || []
  end

  def retrieve_collection
    @collection = Collection.find_by_uuid(params[:id])
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, short:true }
  end
end
