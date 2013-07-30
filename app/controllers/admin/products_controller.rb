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
  
  def mute
    product = Product.find(params[:id])
    product.update_attribute :muted_until, params[:delay].to_i == 0 ? 1.week.from_now : 10.years.from_now
    
    respond_to do |format|
      format.html
      format.js { }
    end
  end   

end
