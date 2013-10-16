class Developers::DevelopersController < ActionController::Base
  before_filter :authenticate_developer!
  layout 'developers'
end