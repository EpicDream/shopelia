class Admin::CollectionsController < Admin::AdminController
  before_filter :retrieve_collection, :only => [:show, :edit, :update]

  def index
    @collections = Collection.where("collections.name is not null").order("collections.created_at DESC")
    @tags = @collections.joins(:tags).map(&:tags).map{|t| t.first.name}.uniq
  end

  def show
  end

  def new
    @collection = Collection.create
  end

  def update
    @collection.update_attributes params[:collection]
    redirect_to edit_admin_collection_path(@collection)
  end

  private

  def retrieve_collection
    @collection = Collection.find_by_uuid!(params[:id].scan(/^[^\-]+/))
  end
end
