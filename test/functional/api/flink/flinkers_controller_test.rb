require 'test_helper'

class Api::Flink::FlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    Rails.cache.delete(:flinker)
    @flinker = flinkers(:elarch)
    sign_in @flinker
  end

  test "it should get publishing flinkers" do
    get :index, format: :json
    assert_response :success
    
    assert_equal 4, json_response["flinkers"].count
  end
  
  test "it should get publishing staff picked flinkers" do
    get :index, staff_pick:1, page:1, format: :json
    assert_response :success
    
    assert_equal 3, json_response["flinkers"].count
  end

  test "it should get publishing non staff picked flinkers" do
    get :index, staff_pick:0, page:1, format: :json
    assert_response :success
    
    assert_equal 1, json_response["flinkers"].count
  end
  
  test "get staff picked flinkers with coutry filter" do
    get :index, staff_pick:1, page:1, country_iso:'fr', format: :json
    assert_response :success
    
    assert_equal 2, json_response["flinkers"].count
  end
  
end
