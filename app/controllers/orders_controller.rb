class OrdersController < ApplicationController

  def show
    @order = Order.find_by_uuid!(params[:id])
  end

end
