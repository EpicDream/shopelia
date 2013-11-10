class Admin::CollectionItemsController < Admin::AdminController
  before_filter :retrieve_item, :only => [:show, :destroy]

  def create
    @items = []
    if params[:urls].present?
      collection = Collection.find(params[:collection_id])
      params[:urls].split(/\r?\n/).each do |url| 
        logger.error url
        item = CollectionItem.new(url:url, collection_id:collection.id) 
        if item.save
          @items << item 
        else
          logger.error item.errors.full_messages.inspect
        end
      end
    else
      item = CollectionItem.new(params[:collection_item])
      @items << item if item.save
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
