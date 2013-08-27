class Api::Vulcain::MerchantsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_merchant, :only => :update

  api :PUT, "/viking/merchants/:vendor", "Update merchant information"
  param :pass, "Boolean", "Did the vulcain strategy test pass ?", :required => true
  param :output, "String", "Output result of the strategy test", :required => true
  def update
    @merchant.vulcain_test_pass = params[:pass]
    @merchant.vulcain_test_output = params[:output]

    if @merchant.save
      head :no_content
    else
      render json: @merchant.errors, status: :unprocessable_entity
    end
  end

  def retrieve_merchant
    @merchant = Merchant.find_by_vendor!(params[:id].camelize)
  end
end
