class Admin::LookProductsController < Admin::AdminController
  before_filter :retrieve_item, :only => [:show, :destroy]

  def show
    redirect_to @item.product.url
  end
  
  def destroy
    @item.destroy
    respond_to do |format|
      format.js
    end
  end    

  private

  def retrieve_item
    @item = LookProduct.find(params[:id])
  end
end