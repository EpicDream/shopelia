class Api::Flink::ActivitiesController < Api::Flink::BaseController

  api :GET, "/activities", "Get current flinkers activities related to him"
  def index
    render json: { activities: activities() }
  end

  private

  def activities
    since = params[:since] ? params[:since].to_i : 1.week
    serialize Activity.for_flinker(current_flinker, since)
  end
  
end
