require 'test_helper'

class Api::Flink::Hashtags::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "get looks with comments containing any given hashtags" do
    Comment.update_all(body:"wha #beautiful !")
    get :index, format: :json, hashtag:"#beautiful"
    
    assert_response :success
    
    looks = json_response["looks"]

    assert_equal 1, looks.count
    assert_equal flinkers(:betty).id, looks.first["flinker"]["id"]
  end
  
end