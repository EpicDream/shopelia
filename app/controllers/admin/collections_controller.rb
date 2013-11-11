class Admin::CollectionsController < Admin::AdminController
  before_filter :retrieve_collection, :only => [:show, :edit, :update, :up, :down]

  def index
    @collections = Collection.where("length(collections.name) > 0").order("rank asc, created_at")
    @tags = @collections.joins(:tags).map(&:tags).map{|t| t.first.name}.uniq
  end

  def show
  end

  def new
    @collection = Collection.create
  end

  def update
    @collection.update_attributes params[:collection]
      respond_to do |format|
        format.html {redirect_to edit_admin_collection_url(@collection)}
        format.js
      end
  end

  def up
    @collection.update_attributes(rank:(@collection.rank - 1))
    redirect_to admin_collections_path
  end

  def down
    @collection.update_attributes(rank:(@collection.rank + 1))
    redirect_to admin_collections_path
  end

  private

  def retrieve_collection
    @collection = Collection.find_by_uuid!(params[:id].scan(/^[^\-]+/))
  end
end
