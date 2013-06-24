class Api::V1::Leetchi::NotificationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :prepare_params

  api :GET, "/callback/operations", "Leetchi callback"
  param :operation, String, "JSON encoded operation", :required => true
  def index
    render :json => ""
  end

  private
  
  def prepare_params
    @operation = params[:operation]
  end
  
end
