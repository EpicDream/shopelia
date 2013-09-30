class HomeController < ApplicationController
  layout 'about', :only => [:about]

  def index
  end

  def about
  end

  def connect
    redirect_to session[:return_to] || home_index_path if current_user
  end
end
