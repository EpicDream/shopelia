class DeviseOverride::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    "https://www.shopelia.com"
  end

  def build_resource(hash={})
    self.resource = User.find_by_email_and_visitor(hash[:email], true)
    if self.resource.nil?
      self.resource = resource_class.new_with_session(hash, session)
    else
      self.resource.update_attributes(hash.merge({"visitor":false}))
    end
  end
  
end
