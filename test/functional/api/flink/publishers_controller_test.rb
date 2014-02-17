require 'test_helper'

class Api::Flink::PublishersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    sign_in flinkers(:fanny)
  end
  
  test "get publishing flinkers with looks" do
    get :index, format: :json
    
    assert_response :success
    assert_equal 4, json_response["flinkers"].count
    assert_equal "lilou@flink.com", json_response["flinkers"].first["email"]
  end
  
end
