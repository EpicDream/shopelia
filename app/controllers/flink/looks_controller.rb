class Flink::LooksController < ApplicationController
  layout "flink"

  def show
    @look = Look.with_uuid(params[:id]).first
    @look ||= Look.find(params[:id])
  end

end