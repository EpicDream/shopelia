class Api::V1::CartItemsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params
  before_filter :retrieve_user
  before_filter :retrieve_cart
  before_filter :retrieve_item

  api :POST, "/api/cart_items", "Add new product to user's list"
  param :email, String, "Email of the user", :required => true
  param :product_version_id, Integer, "Product version to add to list", :required => true
  def create
    if @item
      @item.monitor = true
    else
      @item = CartItem.new(
        cart_id:@cart.id, 
        product_version_id:@product_version.id, 
        developer_id:@developer.id, 
        tracker:@tracker)
    end
    
    if @item.save
      render json: CartItemSerializer.new(@item).as_json, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def prepare_params
    @email = params[:email]
    @product_version = ProductVersion.find(params[:product_version_id])
  end
    
  def retrieve_user
    @user = User.find_by_email(@email)
    if @user.nil?
      @user = User.create(
        :email => @email,
        :ip_address => request.remote_ip,
        :visitor => true,
        :developer_id => @developer.id,
        :tracker => @tracker)
    end
    @device.update_attribute :user_id, @user.id unless @device.nil?
  end
  
  def retrieve_cart
    @cart = Cart.find_or_create_by_user_id(@user.id)
  end

  def retrieve_item
    @item = CartItem.find_by_cart_id_and_product_version_id(@cart.id, @product_version.id)
  end

end
