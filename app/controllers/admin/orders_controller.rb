class Admin::OrdersController < Admin::AdminController
  before_filter :prepare_filters, :only => :index

  def index
    respond_to do |format|
      format.html
      format.json { render json: OrdersDatatable.new(view_context, @filters) }
    end
  end

  def show
    @order = Order.find_by_uuid!(params[:id])
  end

  def update
    @order = Order.find_by_uuid!(params[:id])
    if params[:state].eql?("cancel")
      @order.cancel
    elsif params[:state].eql?("retry")
      @order.start
    end
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { render json: {} }
    end
  end  

  private

  def prepare_filters
    @date_start = params[:date_start].blank? ? Order.order(:created_at).first.created_at : Date.parse(params[:date_start])
    @date_end = params[:date_end].blank? ? Order.order(:created_at).last.created_at : Date.parse(params[:date_end]) + 1.day
    @filters = {
      :date_start => @date_start,
      :date_end => @date_end,
      :state => params[:state].blank? ? Order::STATES : params[:state]
    }
  end
end
