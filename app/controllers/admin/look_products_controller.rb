class Admin::LookProductsController < Admin::AdminController
  before_filter :retrieve_item, :only => [:show, :destroy]

  def show
    redirect_to @item.product.url
  end

  def create
    @items = []
    look = Look.find(params[:look_id])
    if params[:urls].present?
      params[:urls].split(/\r?\n/).each do |url|
        next if url !~ /\Ahttp/
        item = LookProduct.new(url:url, look_id:look.id) 
        @items << item if item.save
      end
    elsif params[:feed].present?
      JSON.parse(params[:feed]).each do |feed|
        next if feed.nil? || feed["product_url"].blank?
        item = LookProduct.new(feed:feed.symbolize_keys, look_id:look.id) 
        @items << item if item.save
      end
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
    @item = LookProduct.find(params[:id])
  end
end