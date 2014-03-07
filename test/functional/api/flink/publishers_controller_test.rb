require 'test_helper'

class Api::Flink::PublishersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    sign_in flinkers(:fanny)
  end
  
  test "publishers with looks ordered by name" do
    get :index, format: :json
    
    assert_response :success
    assert_equal 4, json_response["flinkers"].count
    assert_equal "betty@flink.com", json_response["flinkers"].first["email"]
  end
  
  test "filter by blog name/url matching pattern" do
    get :index, format: :json, blog_name:"nana"
    
    assert_response :success
    assert_equal 1, json_response["flinkers"].count
    assert_equal "nana@flink.com", json_response["flinkers"].first["email"]
  end
  
  test "regexp attack!" do
    get :index, format: :json, blog_name:"char(17)"
    
    assert_response 406
    assert_equal "go suck elsewhere", json_response["status"]
  end
  
end
