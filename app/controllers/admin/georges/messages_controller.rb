class Admin::Georges::MessagesController < Admin::AdminController
  before_filter :retrieve_device

  def index
    @device.authorize_push_channel
    @messages = @device.messages.order(:created_at)
    respond_to do |format|
      format.js
    end
  end

  def create
    @message = @device.messages.build(params[:message].merge(from_admin:true))
    if @message.save
      respond_to do |format|
        format.html { redirect_to admin_georges_device_messages_url(@device)}
        format.js
      end
    else
      
      render :action => 'index'
    end
  end

  def collection_builder
    @collection = Collection.create
    respond_to do |format|
      format.js
    end
  end

  def append_chat
    @message = Message.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def check
    @products = []
    developer = Developer.find_by_name("Shopelia")
    (params[:urls] || "").split(/\r?\n/).compact.each do |url|
      product = Product.fetch(url)
      product.authorize_push_channel
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