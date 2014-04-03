class DeviseOverride::PasswordsController < Devise::PasswordsController

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
     respond_to do |format|
        format.html { redirect_to after_sending_reset_password_instructions_path_for(resource_name) }
        format.js { render "success" }
      end
    else
      respond_to do |format|
        format.html { redirect_to new_user_password_path }
        format.js { render "error" }
      end
    end
  end
  
  protected

  def after_update_path_for(resource)
    root_path
  end

end