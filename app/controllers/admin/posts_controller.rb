class Admin::PostsController < Admin::AdminController
  before_filter :retrieve_post, :only => :show
  
  def index
    @posts = Post.pending_processing.of_country(params[:country_code]).of_blog_with_name(params[:blog_name])
            .order('published_at asc')
    @publications = Look.publications_counts_per_day
  end
  
  def show
    redirect_to admin_look_path(@post.look)
  end

  private

  def retrieve_post
    @post = Post.find(params[:id])
  end
end