class Flink::PublishersLooksController < ApplicationController
  layout "flink"

  def show
    @look = Look.find(params[:id])
  end

end