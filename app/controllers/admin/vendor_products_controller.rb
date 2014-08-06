class Admin::VendorProductsController < Admin::AdminController
  before_filter :retrieve_look_product, only: [:index, :destroy]
  
  def index
  end
  
  def destroy
    # if VendorProduct.create_from_pure_shopping(params[:product_id].to_i, @look_product, params[:similar])
    #   render json:{}, status: 200
    # else
    #   render json:{}, status: 500
    # end
  end
  
  private
  
  def retrieve_look_product
    @look_product = LookProduct.find(params[:look_product_id])
  end
  
end