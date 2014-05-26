require 'test_helper'

class Api::Flink::TrendSettersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:nana)
  end

  test "get trend setters, without completion with top liked" do
    Flinker.stubs(:top_liked).returns([])
    
    get :index, format: :json

    assert_response :success
    assert_equal 1, json_response["flinkers"].count
  end
  
end
