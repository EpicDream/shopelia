require 'scrapers/blogs/blog'

class Admin::BlogsController < Admin::AdminController
  
  def index
    @blogs = Blog.all
  end
  
  def show
    @blog = Blog.find(params[:id])
    blog = Scrapers::Blogs::Blog.new(@blog.url)
    @posts = blog.posts
  end
  
  def create
    @blog = Blog.create(params[:blog])
    redirect_to admin_blog_url(@blog)
  end
  
end