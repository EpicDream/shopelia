class CartItemsController < ApplicationController
  before_filter :retrieve_item

  def unsubscribe
    @item.unsubscribe
    render layout: "zen"
  end
  
  private
  
  def retrieve_item
    @item = CartItem.find_by_uuid!(params[:id])
  end  

end
