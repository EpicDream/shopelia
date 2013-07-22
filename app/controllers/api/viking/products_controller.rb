class Api::Viking::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_product, :only => :update

  def_param_group :product do
    param :product, Hash, :required => true, :action_aware => true do
      param :name, String, "Name", :required => false
      param :image_url, String, "Main image", :required => false
      param :description, String, "Description", :required => false
      param :versions, Hash, "Versions of product", :required => true
    end
  end
  
  api :GET, "/api/viking/products", "Get all products pending check"
  def index
    render json: Product.viking_pending, each_serializer: Viking::ProductSerializer
  end

  api :GET, "/api/viking/products/shift", "Get next product pending check"
  def shift
    product = Product.viking_shift
    if product.present? 
      render json: Viking::ProductSerializer.new(product).as_json[:product]
    else
      render :json => {:error => "Queue is empty"}, :status => :not_found
    end
  end
  
  api :PUT, "/api/viking/products", "Update product"
  param_group :product
  def update
    if @product.update_attributes(params[:product])
      head :no_content
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  private
  
  def retrieve_product
    @product = Product.find(params[:id])
  end
  
end
