class Admin::BlogsController < Admin::AdminController
  before_filter :validates_scope, only: :index
  
  def index
    pagination = Blog.paginate(:page => params[:page], :per_page => 10)
    @blogs = @scopes.inject(pagination){ |acc, scope| acc.send(scope) }.order(:url)
    @blogs = @blogs.with_name_like(params[:pattern])
    render partial:'index' if params[:partial]
  end
  
  def show
    @blog = Blog.where(id:params[:id]).includes(:posts).first
    if params[:fetch]
      BlogsWorker.perform_async(@blog.id) rescue nil
      render json: {}.to_json, status:200
    end
  end
  
  def update
    @blog = Blog.find(params[:id])
    updated =  @blog.update_attributes(params[:blog])
    BlogsWorker.perform_async(@blog.id) if params[:fetch] rescue nil
    respond_to do |format|
      format.html { render :show }
      format.json { render json: {}.to_json, status: updated ? 200 : 500 }
    end
  rescue
    flash.now[:error] = "Erreur lors de la mise à jour"
    render :show
  end
  
  def create
    blog = Blog.create(params[:blog])
    if blog.valid?
      BlogsWorker.perform_async(blog.id) rescue nil
    else
      flash[:error] = blog.errors.full_messages
    end
    
    redirect_to admin_blogs_url
  end
  
  private
  
  def validates_scope
    @scopes = params[:scope] ? params[:scope].split('.') : [:scraped]
    valid = ['scraped', 'scraped.without_posts_since_15_days', 'scraped.without_look_published', 'skipped', nil].include?(params[:scope])
    redirect_to :root unless valid
  end
  
end