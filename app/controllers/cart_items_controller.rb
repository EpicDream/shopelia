class CartItemsController < ApplicationController
  before_filter :authenticate_user!, :only => :create
  before_filter :retrieve_item, :only => :unsubscribe
  before_filter :retrieve_url, :only => :create

  def create
    @item = @current_cart.cart_items.create(
      url:@url,
      developer_id:@developer.id,
      tracker:@tracker)
  end

  def unsubscribe
    @item.unsubscribe
    render layout: "zen"
  end
  
  private
  
  def retrieve_item
    @item = CartItem.find_by_uuid!(params[:id])
  end  

  def retrieve_url
    @url = params[:cart_item][:url]
    @url = "bad url" if @url.blank?
  end
end