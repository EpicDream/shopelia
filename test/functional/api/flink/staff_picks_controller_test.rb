require 'test_helper'

class Api::Flink::StaffPicksControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    sign_in flinkers(:fanny)
  end
  
  test "get staff picked flinkers publishers with looks, universal or of user country" do
    @request.env["X-Flink-Country-Iso"] = "FR"
    
    get :index, format: :json
    
    assert_response :success
    assert_equal 3, json_response["flinkers"].count
  end
  
  test "if none staff picked for user country, send french and universal ones" do
    @request.env["X-Flink-Country-Iso"] = "AZ"
    
    get :index, format: :json
    
    assert_response :success
    assert_equal 3, json_response["flinkers"].count
  end
  
end