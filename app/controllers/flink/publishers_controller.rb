class Flink::PublishersController < ApplicationController
  layout "flink"

  def show
    @publisher = Flinker.find(params[:id])
  end

end