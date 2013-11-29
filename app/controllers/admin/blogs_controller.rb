class Admin::BlogsController < Admin::AdminController
  
  def index
    @blogs = Blog.order(:url)
  end
  
  def show
    @blog = Blog.where(id:params[:id]).includes(:posts).first
    if params[:fetch]
      BlogsWorker.perform_async(@blog.id)
      render json: {}.to_json, status:200
    end
  end
  
  def create
    blogs_from_params.each do |blog_params|
      @blog = Blog.new(blog_params)
      if @blog.save
        BlogsWorker.perform_async(@blog.id)
      end
    end
    redirect_to admin_blogs_url
  end
  
  private
  
  def blogs_from_params
    return [] unless params[:blog]
    return [params[:blog]] unless params[:blog][:csv]
    blogs = []
    CSV.parse(params[:blog][:csv].tempfile.open.read) do |row|
      blogs << {name:row[1], url:row[0]}
    end
    blogs
  end
  
end