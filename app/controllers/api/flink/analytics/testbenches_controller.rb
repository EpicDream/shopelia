class Api::Flink::Analytics::TestbenchesController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  skip_before_filter :authenticate_developer!
  
  def index
    flinker = Flinker.find(356)
    flinker.update_attributes(likes_count: rand(1..100))
    head :no_content
  end
  
end
