class Admin::CollectionItemsController < Admin::AdminController
  before_filter :retrieve_item, :only => [:show, :destroy]

  def create
    if params[:urls].present?
      collection = Collection.find(params[:collection_id])
      params[:urls].split(/\r?\n/).each { |url| CollectionItem.create(url:url, collection_id:collection.id) unless url =~ /^https/ }
      redirect_to edit_admin_collection_path(collection)
    else
      @item = CollectionItem.create(params[:collection_item])
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  
  def retrieve_item
    @item = CollectionItem.find(params[:id])
  end  
end
