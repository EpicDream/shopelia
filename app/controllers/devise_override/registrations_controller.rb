class DeviseOverride::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    home_index_path
  end
end
