class Admin::VendorProductsController < Admin::AdminController
  before_filter :retrieve_look_product, only: [:index]
  before_filter :retrieve_vendor_product, only: [:destroy, :update]
  
  def index
  end
  
  def update
    if @product.update_attributes(params[:vendor_product])
      render json:{}, status:200
    else
      render json:{}, status:500
    end
  end
  
  def destroy
    @product.destroy
  end
  
  private
  
  def retrieve_look_product
    @look_product = LookProduct.find(params[:look_product_id])
  end
  
  def retrieve_vendor_product
    @product = VendorProduct.find(params[:id])
  end
  
end