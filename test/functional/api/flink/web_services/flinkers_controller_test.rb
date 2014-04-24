require 'test_helper'

class Api::Flink::WebServices::FlinkersControllerTest < ActionController::TestCase     

  setup do
    ENV['API_KEY'] = nil
  end
  
  test "ensure API key" do
    get :show, format: :json, uuid:'z3t459o0'
    
    assert_response 401
  end
  
  test "get flinker" do
    follow(flinkers(:betty), flinkers(:fanny))
    @request.env['X-Shopelia-ApiKey'] = "abcdf"
    
    get :show, format: :json, uuid:'z3t459o0'
    
    flinker = json_response
    assert_response :success
    
    assert_equal 'z3t459o0', flinker["uuid"]
    assert_equal "bettyusername", flinker["username"]
    assert_equal 1, flinker["counters"]["looks"]
    assert_equal 1, flinker["counters"]["followers"]
    assert_equal 2, flinker["counters"]["likes"]
  end
  
  test "flinker not found with given uuid" do
    @request.env['X-Shopelia-ApiKey'] = "abcdf"
    
    get :show, format: :json, uuid:'dracula'
    
    assert_response 404
  end
  
end