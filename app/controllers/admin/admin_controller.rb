class Admin::AdminController < ApplicationController
  before_filter :set_locale
  layout 'admin'

  private
  
  def set_locale
    #I18n.locale = "en"
  end
end
