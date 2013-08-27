class Api::Viking::MerchantsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_merchant, :only => [:show, :update, :create]
  before_filter :retrieve_merchant_by_url, :only => [:index]

  def_param_group :merchant do
    param :merchant, Hash, :required => true, :action_aware => true do
      param :data, Hash, "Data to save for viking purposes", :required => true
    end
  end
  
  api :GET, "/viking/merchants", "Get merchant by url"
  def index
    render json: Object::Viking::MerchantSerializer.new(@merchant).as_json[:merchant]
  end 

  api :GET, "/viking/merchants/:id", "Get merchant information"
  def show
    render json: Object::Viking::MerchantSerializer.new(@merchant).as_json[:merchant]
  end

  api :PUT, "/viking/merchants/:id", "Update merchant information"
  param_group :merchant
  def update
    if @merchant.update_attribute :viking_data, params[:data].to_json
      head :no_content
    else
      render json: @merchant.errors, status: :unprocessable_entity
    end
  end

  private
  
  def retrieve_merchant
    @merchant = Merchant.find(params[:id])
  end

  def retrieve_merchant_by_url
    @merchant = Merchant.from_url(params[:url])
  end
end
