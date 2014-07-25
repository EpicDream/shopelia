class Flink::ExplorerController < ApplicationController
  CATEGORY_FILTERS = [:flink_loves, :recent, :popular]
  layout "flink"

  def show
    @covers = Look.covers.send(category).paginate(per_page:20, page:params[:page])
    
    render partial: 'covers' if request.xhr?
  end
  
  private
  
  def category
    category = params[:category].to_sym
    return :flink_loves unless CATEGORY_FILTERS.include?(category)
    p category
    category
  end

end