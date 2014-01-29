class FlinkController < ApplicationController
  layout "flink"

  def index
  end

  def terms

  end

  def download
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    if user_agent.match(/iphone/) || user_agent.match(/ipod/) || user_agent.match(/ipad/)
      redirect_to "https://itunes.apple.com/fr/app/shopelia-lachat-facile-!/id731471392?mt=8"
    else
      redirect_to "/"
    end
  end
end