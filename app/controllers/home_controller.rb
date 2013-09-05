class HomeController < ApplicationController
  layout 'about', :only => [:about]
  def index
  end

  def about
  end
end
