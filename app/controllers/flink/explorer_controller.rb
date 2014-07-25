class Flink::ExplorerController < ApplicationController
  layout "flink"

  def index
    @covers = Look.covers.paginate(per_page:20, page:params[:page])
    
    render partial: 'covers' if request.xhr?
  end

end