class Admin::LooksController < Admin::AdminController
  before_filter :retrieve_look, :only => [:show, :publish, :reject, :reinitialize_images]
  before_filter :retrieve_brands, :only => [:show]
  
  def index
    since = params[:since] || Time.now - 1.week
    @looks = Look.flink_published_between(since, nil).order('flink_published_at desc')
  end
  
  def reinitialize_images
    @look.post.reinitialize_images
    redirect_to admin_look_path(@look.reload)
  end
  
  def publish
    set_published(true)
  end

  def reject
    set_published(false)
  end

  private

  def set_published is_published
    if @look.update_attributes(is_published: is_published) && @look.mark_post_as_processed
      look = Post.where("processed_at is null and look_id is not null").order("published_at desc").first.try(:look)
      redirect_to look ? admin_look_path(look) : admin_posts_path
    else
      flash[:error] = "La publication a échoué"
      redirect_to admin_look_path(@look)
    end
  end

  def retrieve_look
    @look = Look.find(params[:id])
  end
  
  def retrieve_brands
    @brands =  LookProduct.select("distinct brand").map(&:brand).compact
  end
end