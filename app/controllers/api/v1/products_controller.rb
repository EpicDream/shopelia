class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params, :only => :index
  
  api :GET, "/api/products", "Get product information"
  param :url, String, "Url of the product to get", :required => true
  def index
    if @product
      render :json => ProductSerializer.new(@product).as_json[:product]
    else
      head :not_found
    end
  end

  private
  
  def prepare_params
    @product = Product.fetch(params[:url])
    if @product.persisted?
      # retrieve created versions
      @product.reload
    else
      @product = nil 
    end
  end
  
end
