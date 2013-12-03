class Admin::LooksController < Admin::AdminController
  before_filter :retrieve_look, :only => [:show, :publish, :reject]
  
  def index
    @looks = Look.all
  end
  
  def publish
    set_published(true)
  end

  def reject
    set_published(false)
  end

  private

  def set_published is_published
    @look.update_attributes(is_published: is_published)
    @look.mark_post_as_processed
    redirect_to admin_posts_path
  end

  def retrieve_look
    @look = Look.find(params[:id])
  end
end