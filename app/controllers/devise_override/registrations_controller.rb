class DeviseOverride::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    "https://www.shopelia.com"
  end
end
