class Api::V1::MerchantsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_merchant

  api :GET, "/merchants", "Get all available merchants"
  def index
    if params[:url].present?
      render json: @merchant ? MerchantSerializer.new(@merchant).as_json[:merchant] : {}
    else
      render json: ActiveModel::ArraySerializer.new(Merchant.accepting_orders)
    end
  end

  api :POST, "/merchants", "Get merchant for a specific url"
  param :url, String, "Url of the product to order", :required => true
  def create
    if @merchant
      render json: MerchantSerializer.new(@merchant).as_json
    else
      head :not_found
    end
  end
  
  private
  
  def retrieve_merchant
    @merchant = Merchant.from_url(params[:url], false)
  end
  
end
