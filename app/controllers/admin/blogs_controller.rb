class Admin::BlogsController < Admin::AdminController
  before_filter :validates_scope, only: :index
  
  def index
    pagination = Blog.paginate(:page => params[:page], :per_page => 10)
    @blogs = @scopes.inject(pagination){ |acc, scope| acc.send(scope) }.order(:url)
    render partial:'index' if params[:partial]
  end
  
  def show
    @blog = Blog.where(id:params[:id]).includes(:posts).first
    if params[:fetch]
      BlogsWorker.perform_async(@blog.id)
      render json: {}.to_json, status:200
    end
  end
  
  def create
    blog = Blog.create(params[:blog])
    BlogsWorker.perform_async(blog.id) rescue nil
    redirect_to admin_blogs_url
  end
  
  private
  
  def validates_scope
    @scopes = params[:scope] ? params[:scope].split('.') : [:scraped]
    valid = ['scraped', 'scraped.without_posts', 'not_scraped', 'skipped', nil].include?(params[:scope])
    redirect_to :root unless valid
  end
  
end