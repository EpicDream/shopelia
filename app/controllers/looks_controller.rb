class LooksController < ApplicationController
  layout "share"

  def show
    @look = Look.find_by_uuid!(params[:id].scan(/^[^\-]+/))
  end

end