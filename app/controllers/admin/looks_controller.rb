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
  end
  
  def update
    if @look.update_attributes(params[:look])
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
    @look.publish and next_look
  end
  
  def prepublish
    @look.prepublish and next_look
  end

  def reject
    next_look
  end
  
  def reject_quality
    @look.reject_quality and next_look
  end
  
  def highlight_with_tag
    if params[:highlight] == "true"
      HighlightedLook.create(look_id: @look.id, hashtag_id:params[:hashtag_id])
    else
      HighlightedLook.where(look_id: @look.id, hashtag_id:params[:hashtag_id]).destroy_all
    end
    render partial:'form', status: :ok
  end
  
  def add_hashtags_from_staff_hashtags
    Hashtag.create_hashtags_from_staff_hashtags(@look, params[:staff_hashtag_ids])
    render partial:'form', status: :ok
  end

  private
  
  def next_look
    unless @look.mark_post_as_processed
      flash[:error] = "La publication a échoué"
      redirect_to admin_look_path(@look) and return 
    end
    
    look = if @look.prepublished && @look.published
      Look.next_for_publication.first
    else
      Post.next_post.first.try(:look)
    end
    
    redirect_to look ? admin_look_path(look) : admin_posts_path
  end

  def retrieve_look
    @look = Look.find(params[:id])
  end
  
  def retrieve_brands
    @brands = LookProduct.select("distinct brand").map(&:brand).compact
  end
end