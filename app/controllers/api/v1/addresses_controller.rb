class Api::V1::AddressesController < Api::V1::BaseController
  before_filter :retrieve_address, :only => [:show, :update, :destroy]
  
  def_param_group :address do
    param :address, Hash, :required => true, :action_aware => true do
      param :code_name, String, "Address memo name", :required => false
      param :company, String, "Company name", :required => false
      param :address1, String, "First line of address", :required => true
      param :address2, String, "Second line of address", :required => false
      param :city, String, "City of address", :required => true
      param :zip, String, "Zip code", :required => true
      param :country_id, String, "Country", :required => true
      param :state_id, String, "State", :required => false
      param :is_default, [1, 0], "1 if this is the default address (override previous default address if any)", :required => false
    end
  end
    
  api :GET, "/addresses/:id", "Show an address"
  def show
    render json: AddressSerializer.new(@address).as_json
  end

  api :GET, "/addresses", "Get all addresses from user"
  def index
    render json: ActiveModel::ArraySerializer.new(Address.find_all_by_user_id(current_user.id))
  end
    
  api :POST, "/addresses", "Create a new address"
  param_group :address
  def create
    @address = Address.new(params[:address].merge({ user_id: current_user.id }))

    if @address.save
      render json: AddressSerializer.new(@address).as_json, status: :created
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  api :PUT, "/address/:id", "Update an address"
  param_group :address
  def update
    if @address.update_attributes(params[:address])
      head :no_content
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, "/address/:id", "Destroy an address"
  def destroy
    @address.destroy
    head :no_content
  end
  
  private
  
  def retrieve_address
    @address = Address.where(:id => params[:id], :user_id => current_user.id).first!
  end
  
end
