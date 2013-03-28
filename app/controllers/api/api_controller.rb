class Api::ApiController < ActionController::Base
  before_filter :authenticate_developer!
  before_filter :authenticate_user!  

  rescue_from ActiveRecord::RecordNotFound do |e|
    render :json => {:error => e.message}, :status => :not_found
  end
  
  private
  
  def authenticate_developer!
    dev = Developer.find_by_api_key(params[:api_key] || ENV['API_KEY'])
    if dev.nil?
      render json: { error:I18n.t('developers.unauthorized') }, status: :unauthorized
    end
  end

end
