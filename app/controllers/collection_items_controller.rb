class CollectionItemsController < ApplicationController
  before_filter :retrieve_item, :only => :show
  layout :false
  
  def show
  end

  private
  
  def retrieve_item
    @item = CollectionItem.find(params[:id])
  end  
end