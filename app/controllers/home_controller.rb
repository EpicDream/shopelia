class HomeController < ApplicationController
  layout 'about', :only => [:about]

  def index
    if params[:from_signin]
      sign_out(current_flinker) if current_flinker
      render 'after_signin', layout:'flink'
    else
      redirect_to :root
    end
  end
end
