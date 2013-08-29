class Admin::MerchantsController < Admin::AdminController
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: MerchantsDatatable.new(view_context) }
    end
  end

end
