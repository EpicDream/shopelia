class Admin::ProductsController < Admin::AdminController

  def retry
    product = Product.find(params[:id])
    product.update_attributes(
      :viking_failure => nil,
      :versions_expires_at => nil)
    
    respond_to do |format|
      format.html
      format.js { }
    end
  end

end
