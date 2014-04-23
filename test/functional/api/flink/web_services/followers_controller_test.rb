require 'test_helper'

class Api::Flink::WebServices::FollowersControllerTest < ActionController::TestCase     

  setup do
    ENV['API_KEY'] = nil
  end
  
  test "ensure API key" do
    get :count, format: :json
    
    assert_response 401
  end
  
  test "get flinker followers count" do
    follow(flinkers(:betty), flinkers(:fanny))
    @request.env['X-Shopelia-ApiKey'] = "abcdf"
    
    get :count, format: :json, username:'bettyusername'
    
    assert_response :success
    assert_equal 1, json_response["followers"]["count"]
  end
  
  test "flinker not found with given username" do
    @request.env['X-Shopelia-ApiKey'] = "abcdf"
    
    get :count, format: :json, username:'dracula'
    
    assert_response 404
  end
  
end