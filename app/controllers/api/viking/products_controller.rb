class Api::Viking::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  
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

end
