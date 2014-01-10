class LooksController < ApplicationController
  layout "share"

  def show
    @look = Look.find_by_uuid!(params[:id].scan(/^[^\-]+/))
    @avatar = Blog.find_by_url(@look.flinker.url).avatar_url
  end

end