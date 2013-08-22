class CartItemsController < ApplicationController
  layout 'zen'
  before_filter :retrieve_item

  def unsubscribe
    @item.unsubscribe
  end
  
  private
  
  def retrieve_item
    @item = CartItem.find_by_uuid!(params[:id])
  end  

end
