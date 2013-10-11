class HomeController < ApplicationController
  layout 'about', :only => [:about]

  def download
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    if user_agent.match(/android/)
      redirect_to "market://details?id=com.shopelia.android.application"
    elsif user_agent.match(/iphone/) || user_agent.match(/ipod/) || user_agent.match(/ipad/)
      redirect_to "http://itunes.apple.com/fr/app/prixing/id423317030?mt=8&ls=1"
    else
      redirect_to "/"
    end
  end

  def connect
    redirect_to session[:return_to] || home_index_path if current_user
  end
end
