require 'test_helper'

class Api::Flink::FlinkersSearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:fanny)
  end
  
  test "search flinkers by username with username matching" do
    get :index, username:"fann", format: :json
    
    assert_response :success
    assert_equal 1, json_response["flinkers"].count
    assert_equal "nicolasbigot@icloud.com", json_response["flinkers"].first["email"]
  end
  
  test "search flinkers by username with username not matching" do
    get :index, username:"zeta", format: :json

    assert_response :success
    assert_equal 0, json_response["flinkers"].count
  end
  
  test "search flinkers by username with blank username pattern return all flinkers" do
    get :index, username:nil, format: :json

    assert_response :success
    assert_equal 8, json_response["flinkers"].count
  end
  
end
