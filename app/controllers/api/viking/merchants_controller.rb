class Api::Viking::MerchantsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_merchant, :only => [:show, :update, :create, :link]
  before_filter :retrieve_merchant_by_url, :only => [:index]

  def_param_group :merchant do
    param :merchant, Hash, :required => true, :action_aware => true do
      param :data, Hash, "Data to save for viking purposes", :required => true
    end
  end
  
  api :GET, "/viking/merchants", "Get merchant by url"
  def index
    if @merchant
      render json: Object::Viking::MerchantSerializer.new(@merchant).as_json[:merchant]
    else
      h = {totalCount: Merchant.count, supportedBySaturn: Merchant.where("viking_data is not NULL").select("id").map(&:id).sort}
      render json: h.to_json
    end
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

  api :POST, "/viking/merchants/:id", "Update merchant information"
  def link
    if Mapping.find(params[:data]).present?
      @merchant.update_attributes mapping_id: params[:data]
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
    @merchant = Merchant.from_url(params[:url], false)
  end
end
