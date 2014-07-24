class FlinkController < ApplicationController
  layout "flink-fashion"

  def index
    if request.xhr?
      render partial: 'covers'
    end
  end

end