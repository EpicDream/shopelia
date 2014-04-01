class Admin::Search::LooksController < Admin::AdminController
  
  def index
    keywords = params[:keywords] ? params[:keywords].split(",") : []
    @looks = Look.search(keywords)
  end
  
end