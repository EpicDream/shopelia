# -*- encoding : utf-8 -*-
class DeviseOverride::ConfirmationsController < Devise::ConfirmationsController

  protected
    def after_confirmation_path_for(resource_name, resource)
       edit_user_path(resource)
    end

end