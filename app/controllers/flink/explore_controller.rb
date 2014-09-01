class Flink::ExploreController < ApplicationController
  CATEGORY_FILTERS = [:flink_loves, :recent, :popular]
  layout "flink"

  def show
    if is_mobile_device? && !request.xhr?
      @covers_flink_loves = Look.covers.includes(:hashtags).send(:flink_loves).paginate(per_page: 20, page: params[:page])
      @covers_popular = Look.covers.includes(:hashtags).send(:popular).paginate(per_page: 20, page: params[:page])
      @covers_recent = Look.covers.includes(:hashtags).send(:recent).paginate(per_page: 20, page: params[:page])
      @covers = (@covers_flink_loves + @covers_popular + @covers_recent).uniq
    else
      @category = category
      @covers = Look.covers.includes(:hashtags).send(@category).paginate(per_page: 20, page: params[:page])
      render partial: 'covers.mobile.html.erb', :locals => {:covers => @covers} if request.xhr? && is_mobile_device?
      render partial: 'covers.html.erb' if request.xhr? && !is_mobile_device?
    end
  end
  
  private
  
  def category
    category = (params[:category] || :flink_loves).to_sym
    return :flink_loves unless CATEGORY_FILTERS.include?(category)
    category
  end

end