class Admin::LooksController < Admin::AdminController
  before_filter :retrieve_look, :only => [:show, :publish, :reject]
  
  def index
    @looks = Look.all
  end
  
  def publish
    @look.update_attributes(:is_published, true)
    redirect_to admin_posts_path
  end

  def reject
    @look.update_attributes(:is_published, false)
    redirect_to admin_posts_path
  end

  private

  def retrieve_look
    @look = Look.find(params[:id])
  end
end