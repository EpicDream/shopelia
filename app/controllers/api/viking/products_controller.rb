class Api::Viking::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_product, :only => :update
  before_filter :retrieve_versions, :only => :update

  def_param_group :product do
    param :product, Hash, :required => true, :action_aware => true do
      param :name, String, "Name", :required => false
      param :image_url, String, "Main image", :required => false
      param :description, String, "Description", :required => false
      param :versions, Hash, "Versions of product", :required => true
    end
  end
  
  api :GET, "/viking/products", "Get all products pending check"
  def index
    products = params[:batch] ? Product.viking_pending_batch : Product.viking_pending
    products.each { |p| p.viking_reset }
    render json: products, each_serializer: Viking::ProductSerializer
  end
 
  api :GET, "/viking/products/failure", "Get all products which failed with Viking extraction"
  def failure
    render json: Product.viking_failure, each_serializer: Viking::ProductSerializer
  end

  api :GET, "/viking/products/failure_shift", "Get next product which failed Viking extraction"
  def failure_shift
    product = Product.viking_failure.first
    if product.present? 
      render json: Viking::ProductSerializer.new(product).as_json[:product]
    else
      render :json => {}
    end
  end

  api :GET, "/viking/products/shift", "Get next product pending check"
  def shift
    product = params[:batch] ? Product.viking_shift_batch : Product.viking_shift
    if product.present? 
      render json: Viking::ProductSerializer.new(product.viking_reset).as_json[:product]
    else
      render :json => {}
    end
  end
  
  api :PUT, "/viking/products", "Update product"
  param_group :product
  def update
    if @versions.blank?
      @product.update_column "viking_failure", true
      @product.update_column "versions_expires_at", Product.versions_expiration_date
      @product.update_column "updated_at", Time.now
      head :no_content
    elsif @product.update_attributes(
        versions:@versions,
        options_completed:@options_completed)
      head :no_content
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  api :GET, "/viking/products/alive", "Monitor Viking activity for Nagios"
  def alive
    render :json => {:alive => Viking.saturn_alive? ? 1 : 0 }
  end

  private
  
  def retrieve_product
    @product = Product.find(params[:id])
  end
  
  def retrieve_versions
    @versions = params[:versions]
    @options_completed = params[:options_completed]
  end
  
end
