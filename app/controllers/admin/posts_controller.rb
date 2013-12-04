class Admin::PostsController < Admin::AdminController
  before_filter :retrieve_post, :only => :show
  
  def index
    @posts = Post.pending_processing
  end
  
  def show
    redirect_to admin_look_path(@post.look)
  end

  private

  def retrieve_post
    @post = Post.find(params[:id])
  end
end