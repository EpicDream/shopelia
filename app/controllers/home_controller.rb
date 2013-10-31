class HomeController < ApplicationController
  layout 'about', :only => [:about]

  def index
    logger.error request.original_url
  end

  def download
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    if user_agent.match(/android/)
      redirect_to "market://details?id=com.shopelia.android.application"
    elsif user_agent.match(/iphone/) || user_agent.match(/ipod/) || user_agent.match(/ipad/)
      redirect_to "https://itunes.apple.com/fr/app/shopelia-lachat-facile-!/id731471392?mt=8"
    else
      redirect_to "/"
    end
  end

  def connect
    redirect_to session[:return_to] || home_index_path if current_user
  end
end
