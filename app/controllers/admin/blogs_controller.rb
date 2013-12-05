class Admin::BlogsController < Admin::AdminController
  
  def index
    scopes = params[:scope] ? params[:scope].split('.') : [:scraped]
    @blogs = scopes.inject(Blog){|acc, scope| acc.send(scope)}.order(:url)
    if params[:partial]
      render partial:'index'
    end
  end
  
  def show
    @blog = Blog.where(id:params[:id]).includes(:posts).first
    if params[:fetch]
      BlogsWorker.perform_async(@blog.id)
      render json: {}.to_json, status:200
    end
  end
  
  def create
    blogs = if params[:blog][:csv]
      csv = params[:blog][:csv].tempfile.open.read
      Blog.batch_create_from_csv(csv)
    else
      Blog.create(params[:blog])
    end
    scrape(blogs) #in background task
    redirect_to admin_blogs_url
  end
  
  private
  
  def scrape blogs
    [blogs].compact.flatten.each { |blog| 
      BlogsWorker.perform_async(blog.id) rescue nil
    }
  end
  
end