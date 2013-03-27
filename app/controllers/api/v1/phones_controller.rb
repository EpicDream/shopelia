class Api::V1::PhonesController < Api::V1::BaseController
  before_filter :retrieve_phone, :only => [:show, :update, :destroy]

  def_param_group :phone do
    param :phone, Hash, :required => true, :action_aware => true do
      param :number, String, "Phone number", :required => true
      param :line_type, String, "Type of the line: #{Phone::LAND} for land line, #{Phone::MOBILE} for mobile line", :required => true
    end
  end

  api :GET, "/addresses/:id", "Show a phone"
  def show
    render json: @phone
  end
  
  api :GET, "/phones", "Get all phones for current user"
  def index
    render json: ActiveModel::ArraySerializer.new(Phone.find_all_by_user_id(current_user.id))
  end

  api :POST, "/phones", "Create a phone for current user"
  param_group :phone
  def create
    @phone = Phone.new(params[:phone].merge({ user_id: current_user.id }))

    if @phone.save
      render json: @phone, status: :created
    else
      render json: @phone.errors, status: :unprocessable_entity
    end
  end

  api :PUT, "/phones/:id", "Update a phone"
  param_group :phone
  def update
    if @phone.update_attributes(params[:phone])
      head :no_content
    else
      render json: @phone.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, "/phones/:id", "Destroy a phone"
  def destroy
    @phone.destroy

    head :no_content
  end
  
  private
  
  def retrieve_phone
    @phone = Phone.where(:id => params[:id], :user_id => current_user.id).first!
  end
  
end
