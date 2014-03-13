class Admin::FlinkersController < Admin::AdminController
  before_filter :prepare_filters, :only => :index
  before_filter :retrieve_flinker, :only => [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: FlinkersDatatable.new(view_context, @filters) }
    end
  end

  def show
    blog = Blog.find_by_flinker_id(@flinker.id)
    @stats = [
      { name:"looks", value:@flinker.looks.where(is_published:true).count, type: :number }
    ]
    @stats << { name:"posts", value:blog.posts.count, type: :number } unless blog.nil?
  end

  def update
    if @flinker.update_attributes(params[:flinker])
      redirect_to admin_flinker_path(@flinker)
    else
      flash[:error] = "La validation a échoué : #{@flinker.errors.full_messages}"
      render :action => 'edit'
    end
  end

  def destroy
    @flinker.destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private

  def retrieve_flinker
    @flinker = Flinker.find(params[:id])
  end

  def prepare_filters
    @filters = {
      :publisher => params[:publisher],
      :staff_pick => params[:staff_pick],
      :country => params[:country],
      :universal => params[:universal]
    }
  end  
end