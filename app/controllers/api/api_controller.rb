class Api::ApiController < ActionController::Base
  before_filter :authenticate_user!

  rescue_from ArgumentError do |e|
    render :json => {:error => e.message}, :status => :bad_request
   end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render :json => {:error => e.message}, :status => :not_found
  end 

end
