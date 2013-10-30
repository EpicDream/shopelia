class CollectionItemsController < ApplicationController
  before_filter :authenticate_user!, :only => :create
  before_filter :retrieve_item, :only => :show
  layout :false
  
  def show
  end

  def create
    @item = CollectionItem.create(params[:collection_item])
  end

  private
  
  def retrieve_item
    @item = CollectionItem.find(params[:id])
  end  
end