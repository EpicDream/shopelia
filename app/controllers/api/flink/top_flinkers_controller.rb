class Api::Flink::TopFlinkersController < Api::Flink::BaseController
  
  def index
    render json: { flinkers: flinkers }
  end
  
  private
  
  def flinkers
    Rails.cache.fetch([:top_flinkers_controller, :index, current_flinker.id], expires_in: 24.hours) do
      flinkers = Flinker.similar_to(current_flinker)
      ActiveModel::ArraySerializer.new(flinkers)
    end
  end
  
end