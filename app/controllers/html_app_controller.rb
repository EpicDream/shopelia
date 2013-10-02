class HtmlAppController < ApplicationController
  after_filter :remove_session_cookie
  layout 'html_app'

  def index
    @product = Product.fetch(params[:url])
  end
  
  private
  
  def remove_session_cookie
    request.session_options[:skip] = true
  end
  
end
