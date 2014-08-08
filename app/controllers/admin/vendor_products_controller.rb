class Admin::VendorProductsController < Admin::AdminController
  before_filter :retrieve_look_product, only: [:index]
  
  def index
  end
  
  def destroy
    @product = VendorProduct.find(params[:id])
    @product.destroy
  end
  
  private
  
  def retrieve_look_product
    @look_product = LookProduct.find(params[:look_product_id])
  end
  
end