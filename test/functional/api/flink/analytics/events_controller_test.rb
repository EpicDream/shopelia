require 'test_helper'

class Api::Flink::Analytics::EventsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @events = [{ event:"seelook", look_uuid:"21234u" }, { event:"seeblog", look_uuid:"21234u" }]
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
  
  test "create notification event" do
    events = [{ event:"openpush", notification_id: 2, read: true }]
    
    assert_difference("Tracking.count") do
      post :create, events: events, format: :json
    end
    
    assert_response :success
  end
  
end