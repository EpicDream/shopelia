class Api::Flink::SessionsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, :only => :create

  api :POST, "/flinkers/sign_in", "Sign in a flinker"
  param :email, String, "Email of the flinker", :required => true
  param :password, String, "Password of the flinker", :required => true
  def create
    resource = Flinker.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      sign_in(:flinker, resource)
      resource.ensure_authentication_token!
      render json: FlinkerSerializer.new(resource).as_json.merge({auth_token:resource.authentication_token})
      return
    end
    invalid_login_attempt
  end

  api :DELETE, "/flinkers/sign_out", "Sign out a flinker"
  param :email, String, "Email of the flinker", :required => true
  def destroy
    flinker = Flinker.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless flinker
    flinker.authentication_token = nil
    flinker.save
    render json: {}
  end

  protected

  def invalid_login_attempt
    render json: { error:I18n.t('devise.failure.invalid') }, status: :unauthorized
  end
end