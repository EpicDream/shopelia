require 'test_helper'

class Api::Flink::TrendSettersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
  end

  test "get trend setters, without completion with top liked" do
    sign_in flinkers(:nana)
    Flinker.stubs(:top_liked).returns([])
    
    get :index, format: :json

    assert_response :success
    assert_equal 1, json_response["flinkers"].count
  end
  
  test "get trend setters of country using country iso param when disconnected mode" do
    Flinker.stubs(:top_liked).returns([])
    
    get :index, iso:'FR', format: :json

    assert_response :success
    assert_equal 2, json_response["flinkers"].count
    assert_equal ["bettyusername", "boop"], json_response["flinkers"].map { |f| f["username"] }
  end
  
  
end
