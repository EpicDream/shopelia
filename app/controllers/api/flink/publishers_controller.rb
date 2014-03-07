class Api::Flink::PublishersController < Api::Flink::BaseController
  FLINKERS_ORDER = "name asc"
  before_filter :prevent_regexp_attack!
  
  def index
    render json: { flinkers: serialize(flinkers) }
  end
  
  private
  
  def flinkers
    Flinker.publishers
    .with_looks
    .with_blog_matching(params[:blog_name])
    .paginate(pagination)
    .order(FLINKERS_ORDER)
  end
  
  def prevent_regexp_attack! #handle by rails?
    return if params[:blog_name].blank?
    params[:blog_name] = params[:blog_name][0...20]
    render(json: {"status" => "go suck elsewhere"}, status: 406) unless params[:blog_name] =~ /\A[\w\d\s]+\z/
  end
  
end
