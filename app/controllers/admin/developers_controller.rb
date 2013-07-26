class Admin::DevelopersController < Admin::AdminController
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: DevelopersDatatable.new(view_context) }
    end
  end

  def show
    @developer = Developer.find(params[:id])
  end
  
  def create
    Developer.create(params[:developer])
    redirect_to admin_developers_url
  end
  
end
