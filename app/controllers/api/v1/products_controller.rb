class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params, :only => :index
  
  api :GET, "/api/products", "Extract information from product page"
  param :url, String, "Url of the product to extract", :required => true
  def index
    if @product
      result = Vulcain::ProductInformations.create({
        "vendor" => @product.merchant.vendor,
        "context" => { "url" => @product.url }
      })
      render :json => result.to_json
    else
      head :not_found
    end
  end

  private
  
  def prepare_params
    @product = Product.fetch(params[:url])
    @product = nil unless @product.persisted?
  end
  
end
