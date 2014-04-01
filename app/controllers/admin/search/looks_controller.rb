class Admin::Search::LooksController < Admin::AdminController
  
  def index
    keywords = params[:keywords] ? params[:keywords].split(",") : []
    @looks = Look.search(keywords).paginate(per_page:2, page:params[:page])
  end
  
end