class Api::Viking::MerchantsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :preprocess_params, :only => [:update]
  before_filter :retrieve_merchant, :only => [:show, :update, :create]
  before_filter :retrieve_merchant_by_url, :only => [:index]
  before_filter :preprocess_mapping_id, :only => [:update]

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
      h = {totalCount: Merchant.count, supportedBySaturn: Merchant.where("mapping_id is not NULL").select("id").map(&:id).sort}
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
    if params.size > 0 && @merchant.update_attributes(params)
      head :no_content
    else
      render json: @merchant.errors, status: :unprocessable_entity
    end
  end

  private

  def preprocess_params
    params[:viking_data] = params.delete(:data).to_json if params[:data]
    true
  end

  def retrieve_merchant
    @merchant = Merchant.find(params[:id])
  end

  def retrieve_merchant_by_url
    @merchant = Merchant.from_url(params[:url], false)
  end

  def preprocess_mapping_id
    params.delete(:mapping_id) if params[:mapping_id] && ! Mapping.find(params[:mapping_id]).present?
    true
  end
end
