class Api::V1::UsersController < Api::V1::BaseController
  before_filter :retrieve_user

  def_param_group :user do
    param :user, Hash, :required => true, :action_aware => true do
      param :email, /\A[^@]+@[^@]+\z/, :desc => "Email of the user", :required => true
      param :password, String, "Password of the user", :required => false
      param :password_confirmation, String, "Password confirmation", :required => false
      param :first_name, String, "First name of the user", :required => true
      param :last_name, String, "Last name of the user", :required => true
      param :birthdate, Date, "Birthdate of the user, format YYYY-MM-DD", :required => true
      param :civility, [User::CIVILITY_MR, User::CIVILITY_MME, User::CIVILITY_MLLE], "Civility of the user (#{User::CIVILITY_MR}=Monsieur, #{User::CIVILITY_MME}=Madame, #{User::CIVILITY_MLLE}=Mademoiselle"
      param :pincode, String, "Pin code of the user, to unlock usage", :required => false
      param :addresses_attributes, Array, "Addresses of user", :required => false
      param :phones_attributes, Array, "Mobile phones of user", :required => false
      param :payment_cards_attributes, Array, "Payment cards of user", :required => false
    end
  end

  api :GET, "/users/:id", "Get an user"
  def show
    render json: UserSerializer.new(@user).as_json
  end

  api :PUT, "/users/:id", "Update an user"
  param_group :user
  def update
    success = if need_password?
      if @user.has_password? 
        @user.update_with_password(params[:user])
      else
        @user.update_attributes(params[:user])
      end
    else
      @user.update_without_password(params[:user])
    end
    
    if success
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, "/users/:id", "Destroy an user"
  param :password, String, "Current password of user", :required => true
  def destroy
    if @user.valid_password?(params[:password])
      @user.destroy
      head :no_content
    else
      render json: {}, status: :unprocessable_entity
    end      
  end
  
  private
  
  def retrieve_user
    @user = current_user
  end
  
  def need_password?
    !params[:user][:password].blank?
  end
  
end
