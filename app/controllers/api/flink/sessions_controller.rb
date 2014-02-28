class Api::Flink::SessionsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, :only => :create

  api :POST, "/flinkers/sign_in", "Sign in a flinker"
  param :email, String, "Email of the flinker", :required => true
  param :password, String, "Password of the flinker", :required => true
  
  def create
    render sign_in_by_email and return unless params[:provider]
    flinker = FlinkerAuthentication.facebook(params[:token])
    sign_in(:flinker, flinker)
    flinker.ensure_authentication_token!
    render json_for(flinker)
  rescue => e
    render unauthorized("Facebook token is invalid", e) and return if e.respond_to?(:code) && [400, 401].include?(e.code)
    render server_error(e)
  end
  
  api :DELETE, "/flinkers/sign_out", "Sign out a flinker"
  param :email, String, "Email of the flinker", :required => true
  
  def destroy
    flinker = Flinker.find_for_database_authentication(:email => params[:email])
    render unauthorized and return unless flinker
    flinker.authentication_token = nil
    flinker.save
    flinker.devices.destroy_all
    render json: {}, status: :ok
  end
  
  def update
    render unauthorized and return unless current_flinker
    update_country_iso
    update_lang_iso
    FlinkerAuthentication.facebook(params[:token]) if params[:token]
    render json_for(current_flinker)
  end
  
  private
  
  def update_country_iso
    current_flinker.country_iso = params[:"x-country-iso"]
    current_flinker.country_from_iso_code and current_flinker.save
  end
  
  def update_lang_iso
    current_flinker.update_attributes(lang_iso:params[:"x-user-language"])
  end
  
  def sign_in_by_email
    flinker = Flinker.find_for_database_authentication(email:params[:email])
    return unauthorized unless flinker && flinker.valid_password?(params[:password])
    
    sign_in(:flinker, flinker)
    flinker.ensure_authentication_token!
    json_for(flinker)
  end
  
  def json_for flinker
    { json: FlinkerSerializer.new(flinker).as_json.merge({ auth_token:flinker.authentication_token })}
  end

end