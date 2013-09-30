class DeviseOverride::SessionsController < Devise::SessionsController

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource.nil?
      respond_to do |format|
        format.html { redirect_to new_user_session_path }
        format.js { render "unauthorized" }
      end
    else
      sign_in(resource_name, resource)
      respond_to do |format|
        format.html { redirect_to after_sign_in_path_for(resource) }
        format.js { render "authorized", :locals => {:url => after_sign_in_path_for(resource)} }
      end      
    end
  end

end