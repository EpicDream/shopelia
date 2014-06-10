class Api::Flink::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.published_at desc"
  
  skip_before_filter :authenticate_flinker!
  before_filter { 
    epochs_to_dates [:updated_after, :published_before, :published_after, :flink_published_after, :flink_published_before] 
  }
  
  api :GET, "/looks", "Get looks"
  def index
    render unauthorized and return if params[:liked] && !current_flinker
    render json: { looks: serialize(looks, scope:scope().merge(include_liked_by_friends:true)) }
  end

  private

  def looks
    case
    when params[:uuids]  #TODO:Keep only this on new versions
      Look.published.where(uuid:params[:uuids])
    when params[:looks_ids] #CHANGED:remove?
      Look.published.where(uuid:params[:looks_ids])
    when params[:liked] #CHANGED: => /flink/likes/looks
      flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
      Look.liked_by(flinker).order(LOOKS_ORDER).paginate(pagination)
    when params[:updated_after] #CHANGED: => /flink/followings/updated_looks
      []
      # Look.of_flinker_followings(current_flinker)
      # .updated_after(params[:updated_after])
      # .order('updated_at asc')
      # .paginate(pagination)
    when params[:flinker_ids] #CHANGED: => /flink/flinkers/looks
      Look.where(flinker_id:params[:flinker_ids])
      .published_between(params[:published_after], params[:published_before])
      .order(LOOKS_ORDER)
      .paginate(pagination)
    else #CHANGED: => /flink/followings/looks
      if params[:published_after] || params[:published_before]
        Look.of_flinker_followings(current_flinker)
        .published_between(params[:published_after], params[:published_before])
        .order(LOOKS_ORDER)
        .paginate(pagination)
      else
        Look.of_flinker_followings(current_flinker)
        .flink_published_between(params[:flink_published_after], params[:flink_published_before])
        .order("looks.flink_published_at desc")
        .paginate(pagination)
      end
    end
    #TODO: Lorsque suppresion des when, laisse un published_between pour mode déconnecté
  end

end