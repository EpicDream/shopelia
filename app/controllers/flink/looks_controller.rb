class Flink::LooksController < ApplicationController
  layout "flink"

  def show
    @look = Look.find(params[:id]) rescue nil
    @look ||= Look.with_uuid(params[:id]).first
  end

end