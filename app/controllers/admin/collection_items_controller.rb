class Admin::CollectionItemsController < Admin::AdminController
  before_filter :retrieve_item, :only => [:show, :destroy]

  def create
    @items = []
    collection = Collection.find(params[:collection_id]) if params[:collection_id].present?
    if params[:urls].present?
      params[:urls].split(/\r?\n/).each do |url|
        next if url !~ /\Ahttp/
        item = CollectionItem.new(url:url, collection_id:collection.id) 
        @items << item if item.save
      end
    elsif params[:feed].present?
      JSON.parse(params[:feed]).each do |feed|
        next if feed.nil?
        item = CollectionItem.new(feed:feed.symbolize_keys, collection_id:collection.id) 
        @items << item if item.save
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
