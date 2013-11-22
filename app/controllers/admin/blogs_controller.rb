class Admin::BlogsController < Admin::AdminController
  
  def index
    @blogs = Blog.all
  end
  
  def show
    @blog = Blog.where(id:params[:id]).includes(:posts).first
    if params[:fetch]
      @blog.fetch
    end
  end
  
  def create
    @blog = Blog.new(params[:blog])
    if @blog.save
      redirect_to admin_blog_url(@blog)
    else
      redirect_to admin_blogs_url
    end
  end
  
end