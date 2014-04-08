class Admin::Search::LooksController < Admin::AdminController
  
  def index
    keywords = params[:keywords] ? params[:keywords].split(",") : []
    @looks = Look.search(keywords, params[:country_id]).paginate(per_page:30, page:params[:page])
  end
  
end