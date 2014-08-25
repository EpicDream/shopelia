class Admin::LooksController < Admin::AdminController
  before_filter :retrieve_look, :except => [:index]
  before_filter :retrieve_brands, :only => [:show]
  
  def index
    since = params[:since] || Time.now - 1.week
    @looks = Look.flink_published_between(since, nil)
            .order('flink_published_at desc')
            .paginate(:page => params[:page], :per_page => 40)
  end
  
  def show
    @look.hashtags.build
  end
  
  def update
    if @look.update_attributes(params[:look])
      @look.hashtags.build
      render partial:'form', status: :ok
    else
      render json:{}, status: :error
    end
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
  
  def reject_quality
    set_published(false, true)
  end
  
  def highlight_with_tag
    if params[:highlight] == "true"
      HighlightedLook.create(look_id: @look.id, hashtag_id:params[:hashtag_id])
    else
      HighlightedLook.where(look_id: @look.id, hashtag_id:params[:hashtag_id]).destroy_all
    end
    render partial:'form', status: :ok
  end

  private

  def set_published is_published, quality_rejected=false
    if @look.update_attributes(is_published: is_published, quality_rejected: quality_rejected) && @look.mark_post_as_processed
      look = Post.where("processed_at is null and look_id is not null").order("published_at asc").first.try(:look)
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
    @brands = LookProduct.select("distinct brand").map(&:brand).compact
  end
end