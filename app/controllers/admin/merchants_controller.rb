class Admin::MerchantsController < Admin::AdminController
  before_filter :prepare_filters, :only => :index
  before_filter :retrieve_merchant, :only => [:show, :edit, :update]

  def index
    respond_to do |format|
      format.html
      format.json { render json: MerchantsDatatable.new(view_context, @filters) }
    end
  end

  def show
    orders = @merchant.orders.count
    views = @merchant.events.views.count
    clicks = @merchant.events.clicks.count
    requests = @merchant.events.requests.count
    @stats = [
      { name:"orders", value:orders, type: :number },
      { name:"views", value:views, type: :number },
      { name:"clicks", value:clicks, type: :number },
      { name:"requests", value:requests, type: :number }
    ]

    respond_to do |format|
      format.html
      format.json { render json: Merchants::EventsDatatable.new(view_context, @merchant) }
    end
  end

  def update
    if @merchant.update_attributes(params[:merchant])
      redirect_to admin_merchant_path(@merchant)
    else
      render :action => 'edit'
    end
  end

  private

  def retrieve_merchant
    @merchant = Merchant.find(params[:id])
  end

  def prepare_filters
    @filters = {
      :vulcain => params[:vulcain],
      :saturn => params[:saturn]
    }
  end  
end