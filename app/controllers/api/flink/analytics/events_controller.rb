class Api::Flink::Analytics::EventsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def create
    params[:events].each do |event|
      attrs = event.merge tracking_attributes
      Tracking.create(attrs)
    end
    head :no_content
  end
  
  private
  
  def tracking_attributes
    device_attributes.merge({ flinker_id: current_flinker.try(:id) })
  end
  
end
