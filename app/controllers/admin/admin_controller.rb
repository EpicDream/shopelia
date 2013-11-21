class Admin::AdminController < ActionController::Base
  before_filter :set_locale
  layout 'admin'

  private
  
  def set_locale
    I18n.locale = "fr"
  end
end
