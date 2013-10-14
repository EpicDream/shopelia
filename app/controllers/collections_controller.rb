class CollectionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :add]
  before_filter :find_collection, :only => [:show, :add]
  before_filter :ensure_collection_edit_rights!, :only => [:add, :update]

  def index
    @collections = Collection.order("created_at DESC")
  end

  def create
    @collection = @current_user.collections.build(params[:collection])

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collection_path(@collection) }
        format.js
      else
        format.html { render partial:"new_collection" }
        format.js
      end
    end
  end

  def add
    @item = @collection.collection_product_versions.build(url:params[:url])
    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def find_collection
    @collection = Collection.find_by_uuid!(params[:id].scan(/^[^\-]+/))
  end

  def ensure_collection_edit_rights!
    render status: :unauthorized and return if @current_user.id != @collection.user_id
  end
end