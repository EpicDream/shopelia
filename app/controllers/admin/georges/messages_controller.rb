class Admin::Georges::MessagesController < Admin::AdminController
  before_filter :retrieve_device

  def index
    @messages = @device.messages.order(:created_at)
  end

  def create
    @message = @device.messages.build(params[:message].merge(from_admin:true))

    if @message.save
      redirect_to admin_georges_device_messages_url(@device)
    else
      render :action => 'index'
    end
  end

  def check
    @products = []
    developer = Developer.find_by_name("Shopelia")
    (params[:urls] || "").split(/\r?\n/).compact.each do |url|
      product = Product.fetch(url)
      product.p.authorize_push_channel
      Event.create!(
        :product_id => product.id,
        :action => Event::REQUEST,
        :developer_id => developer.id,
        :tracker => "georges")
      @products << product
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def retrieve_device
    @device = Device.find(params[:device_id])
  end
end