class FlinkController < ApplicationController
  layout "flink-fashion"

  def index
    @covers = Look.covers.paginate(per_page:20, page:params[:page])
    if request.xhr?
      render partial: 'covers'
    end
  end

end