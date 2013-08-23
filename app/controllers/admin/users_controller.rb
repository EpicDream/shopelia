class Admin::UsersController < Admin::AdminController
  before_filter :prepare_graph_params, :only => :index
  
  def index
    @chart = []
    User.where(visitor:@visitor).where("created_at>=? and created_at<=?", @date_start, @date_end).count(:group => "date(created_at)").each do |data|
      @chart << { "date" => data[0], "value" => data[1] }
    end

    respond_to do |format|
      format.html
      format.json { 
        if params[:graph].present?
          render json: @chart
        else
          render json: UsersDatatable.new(view_context) 
        end
      }
    end
  end

  def show
    @user = User.find(params[:id])
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { render json: {} }
    end
  end
  
  private

  def prepare_graph_params
    @date_start = params[:date_start].blank? ? User.order(:created_at).first.created_at : Date.parse(params[:date_start])
    @date_end = params[:date_end].blank? ? User.order(:created_at).last.created_at : Date.parse(params[:date_end]) + 1.day
    @visitor = params[:visitor].blank? ? [true,false] : params[:visitor] == "1" ? true : false
  end

end
