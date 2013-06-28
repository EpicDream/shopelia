class OrdersController < ApplicationController
  before_filter :retrieve_order

  def update
    if params["order"]["confirmation"].eql?("yes")
      @order.accept
    else
      @order.reject "price_rejected"
    end
    redirect_to @order
  end

  private
  
  def retrieve_order
    @order = Order.find_by_uuid!(params[:id])
  end  

end
