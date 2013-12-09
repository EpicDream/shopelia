class Api::Flink::SessionsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, :only => :create

  api :POST, "/flinkers/sign_in", "Sign in a flinker"
  param :email, String, "Email of the flinker", :required => true
  param :password, String, "Password of the flinker", :required => true
  def create
    if !params[:provider].blank? && !params[:token].blank?
      data = FlinkerAuthentication.fetch_data(params[:provider],params[:token])
      if data[:status] == 401
        render json: { error: "facebook token is invalid" } , status: :unauthorized
      else
        flinker_auth = FlinkerAuthentication.find_by_uid(data[:uid])
        flinker = flinker_auth.flinker unless flinker_auth.nil?
        unless flinker
          flinker = Flinker.find_for_database_authentication(:email => data[:email])
          unless flinker
            password = SecureRandom.hex(4)
            flinker = Flinker.create!(email:data[:email],username: data[:username], password:password, password_confirmation:password)
          end
          flinker_auth = FlinkerAuthentication.create!(provider:params[:provider],token:params[:token],uid:data[:uid])
          flinker_auth.flinker = flinker
        end
        flinker_auth.token = params[:token]
        flinker_auth.save
        sign_in(:flinker, flinker)
        flinker.ensure_authentication_token!
        render json: FlinkerSerializer.new(flinker).as_json.merge({auth_token:flinker.authentication_token})
        return
      end
    else
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