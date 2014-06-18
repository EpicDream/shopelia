class Api::Flink::SessionsController < Api::Flink::BaseController#TODO:Refactor this shit
  skip_before_filter :authenticate_flinker!, :only => :create

  def create
    render sign_in_by_email and return unless params[:provider]
    case params[:provider]
    when FacebookAuthentication::FACEBOOK
      flinker, created = FacebookAuthentication.facebook(params[:token])
    when TwitterAuthentication::TWITTER
      flinker, created = TwitterAuthentication.authenticate(params[:token], params[:token_secret], params[:email])
    end
    sign_in(:flinker, flinker)
    flinker.ensure_authentication_token!
    update_attributes_from_headers
    render json_for(flinker, created)
  rescue => e
    render unauthorized("Token is invalid", e) and return if e.respond_to?(:code) && [400, 401, 89].include?(e.code)
    render server_error(e)
  end
  
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
    update_attributes_from_headers
    case params[:provider]
    when FacebookAuthentication::FACEBOOK
      FacebookAuthentication.facebook(params[:token])
    when TwitterAuthentication::TWITTER
      TwitterAuthentication.authenticate(params[:token], params[:token_secret], params[:email])
    end
    render json_for(current_flinker)
  end
  
  private
  
  def update_attributes_from_headers
    current_flinker.country_iso = params[:"x-country-iso"]
    current_flinker.country_from_iso_code and current_flinker.save
    current_flinker.update_attributes(lang_iso:params[:"x-user-language"])
    current_flinker.update_attributes(timezone:params[:"x-user-timezone"])
  end
  
  def sign_in_by_email
    flinker = Flinker.find_for_database_authentication(email:params[:email])
    return unauthorized unless flinker && flinker.valid_password?(params[:password])
    sign_in(:flinker, flinker)
    flinker.ensure_authentication_token!
    update_attributes_from_headers
    json_for(flinker)
  end
  
  def json_for flinker, created=nil
    { json: FlinkerSerializer.new(flinker).as_json.merge({ auth_token:flinker.authentication_token, creation:created })}
  end

end