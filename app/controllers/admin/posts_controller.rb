class Admin::PostsController < Admin::AdminController
  before_filter :retrieve_post, :only => :show
  
  def index
    @posts = Post.where("processed_at is null").order("published_at desc")
  end
  
  def show
    redirect_to admin_look_path(@post.look)
  end

  private

  def retrieve_post
    @post = Post.find(params[:id])
  end
end