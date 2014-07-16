require 'test_helper'

class Api::Flink::FacebookFriendsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:boop)
    FacebookFriend.expects(:create_or_update_friends).with(@flinker)
  end
  
  test "get index of facebook friends" do
    sign_in @flinker
    
    get :index, page:1, format: :json
    
    assert_response :success
    
    assert !json_response["has_next"]
    assert_equal 2, json_response["flinkers"]["facebook"].count
    assert_equal 2, json_response["flinkers"]["flink"].count
    assert_equal "nicolasbigot@icloud.com", json_response["flinkers"]["flink"].first["email"]
  end
  
  test "has next flag" do
    facebook_friends(:bibi).destroy
    sign_in @flinker
    
    get :index, page:1, per_page:1, format: :json
    
    assert_response :success

    assert json_response["has_next"]
    assert_equal 1, json_response["flinkers"]["facebook"].count
    assert_equal 1, json_response["flinkers"]["flink"].count
  end
  
  test "fetch facebook friends if none at request time" do
    sign_in @flinker
    
    FacebookFriend.destroy_all
    
    get :index, page:1, per_page:1, format: :json
    
    assert_response :success
  end
  
  
end
