require 'test_helper'

class Api::Flink::Analytics::EventsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @events = [{ event:"SeeLook", look_uuid:"21234u" }, { event:"SeeBlog", look_uuid:"21234u" }]
  end
  
  test "create events disconnected mode" do
    assert_difference("Tracking.count", 2) do
      post :create, events:@events, format: :json
    end
    
    assert_response :success
  end
  
  test "create events connected mode" do
    sign_in @fanny = flinkers(:fanny)
    
    assert_difference("Tracking.count", 2) do
      post :create, events:@events, format: :json
    end
    
    assert_response :success
    
    Tracking.all { |track| assert_equal(@fanny.id, track.flinker_id) }
  end
  
  
end