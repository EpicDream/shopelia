class Flink::ExploreController < ApplicationController
  CATEGORY_FILTERS = [:flink_loves, :recent, :popular]
  layout "flink"

  def show
    @category = category
    @covers = Look.covers.includes(:hashtags).send(@category).paginate(per_page: 20, page: params[:page])
    render partial: 'covers' if request.xhr?
  end
  
  private
  
  def category
    category = (params[:category] || :flink_loves).to_sym
    return :flink_loves unless CATEGORY_FILTERS.include?(category)
    category
  end

end