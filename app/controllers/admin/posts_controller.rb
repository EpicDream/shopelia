class Admin::PostsController < Admin::AdminController
  
  def index
    @posts = Post.where(status:"#{params[:status] || 'pending'}").order("published_at desc")
  end
  
  def show
    @post = Post.find(params[:id])
    @look = @post.generate_look
    @products, @links = @post.convert
  end
end