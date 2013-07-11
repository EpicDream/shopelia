class Api::V1::MangoPay::NotificationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :prepare_params

  api :GET, "/mangopay/notifications", "MangoPay callback"
  param :operation, String, "JSON encoded operation", :required => true
  def index
    render :json => ""
  end

  private
  
  def prepare_params
    @operation = params[:operation]
  end
  
end
