class Api::Flink::Analytics::EventsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def create
    head :no_content
  end
  
end
