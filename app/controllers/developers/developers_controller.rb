class Developers::DevelopersController < ActionController::Base
  before_filter :authenticate_developer!
  before_filter :set_locale
  layout 'developers'

  def set_locale
    I18n.locale = 'en'
  end
end