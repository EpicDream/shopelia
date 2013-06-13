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

  def update
    @order = Order.find_by_uuid!(params[:id])
    if params[:state].eql?("cancel")
      @order.time_out
    elsif params[:state].eql?("retry")
      @order.start
    end
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { render json: {} }
    end
  end  
end
