class Admin::Search::LooksController < Admin::AdminController
  
  def index
    @looks = Look.search(params[:keywords].split(","))
  end
  
end