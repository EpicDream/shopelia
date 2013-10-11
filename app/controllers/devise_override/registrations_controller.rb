class DeviseOverride::RegistrationsController < Devise::RegistrationsController
  before_filter :retrieve_developer

  def create
    build_resource

    if resource.save
      set_flash_message :notice, :signed_up if is_navigational_format?
      sign_up(resource_name, resource)
      respond_to do |format|
        format.html { redirect_to after_sign_up_path_for(resource) }
        format.js { render "success", locals:{url:after_sign_up_path_for(resource)} }
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.html { redirect_to new_user_session_path(resource) }
        format.js { render "error", locals:{user:resource} }
      end  
    end
  end

  protected

  def after_sign_up_path_for(resource)
    session[:return_to] || home_index_path
  end

  def build_resource(hash=nil)
    hash ||= resource_params || {}
    # avoid creation of user with these blank fields
    hash[:password] = "~" if hash[:password].to_s.length == 0
    hash[:first_name] = "~" if hash[:first_name].to_s.length == 0
    hash[:last_name] = "~" if hash[:last_name].to_s.length == 0
    self.resource = User.find_by_email_and_visitor(hash[:email], true)
    if self.resource.nil?
      self.resource = resource_class.new_with_session(hash.merge({"developer_id" => @developer.id}), session)
    else
      self.resource.update_attributes(hash.merge({"visitor" => false}))
    end
  end

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end
end