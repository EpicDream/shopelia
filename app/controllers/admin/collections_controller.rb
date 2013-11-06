class Admin::CollectionsController < Admin::AdminController
  before_filter :retrieve_collection, :only => [:show, :edit, :update]

  def index
    @collections = Collection.order("collections.created_at DESC")
    @tags = @collections.joins(:tags).select("distinct(tags.name)").map(&:name)
  end

  def show
  end

  def update
    if @collection.update_attributes params[:collection]
      redirect_to admin_collection_path(@collection)
    else
      render "edit"
    end
  end

  private

  def retrieve_collection
    @collection = Collection.find_by_uuid!(params[:id].scan(/^[^\-]+/))
  end
end