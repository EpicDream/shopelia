class Admin::OrdersController < Admin::AdminController
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: OrdersDatatable.new(view_context) }
    end
  end

  def show
    @order = Order.find_by_uuid!(params[:id])
  end
  
end
