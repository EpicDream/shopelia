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
    dev = Developer.new(params[:developer])
    if dev.save
      flash[:success] = "Developer has been successfuly added"
    else
      flash[:error] = dev.errors.full_messages.join(",")
    end

    redirect_to admin_developers_url
  end
  
end
