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
    orders = @user.orders.count
    views = @user.events.views.count
    clicks = @user.events.clicks.count
    @stats = [
      { name:"orders", value:orders, type: :number },
      { name:"follows", value:@user.cart_items.where(monitor:true).count, type: :number },
      { name:"views", value:views, type: :number },
      { name:"clicks", value:clicks, type: :number }
    ]
    if orders > 0 && clicks > 0
      @stats << { 
        name:"time before first order", 
        value: @user.orders.order(:created_at).first.created_at - @user.events.order(:created_at).first.created_at,
        type: :time 
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: Users::EventsDatatable.new(view_context, @user) }
    end
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
