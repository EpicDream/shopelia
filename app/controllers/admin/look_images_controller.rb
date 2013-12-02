class Admin::LookImagesController < Admin::AdminController
  before_filter :retrieve_item, :only => [:update, :destroy]

  def update
    @item.update_attributes(params[:look_image])
    respond_to do |format|
      format.json { head :ok }
    end
  end    

  def destroy
    @item.destroy
    respond_to do |format|
      format.json { head :ok }
    end
  end    

  private

  def retrieve_item
    @item = LookImage.find(params[:id])
  end
end