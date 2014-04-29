require 'test_helper'

class Api::Flink::TopFlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:fanny)
  end

  test "get suggestions for current flinker friends" do
    like(flinkers(:nana), [looks(:agadir), looks(:quimper)])
    like(flinkers(:fanny), [looks(:thaiti)])
    like(flinkers(:boop), [looks(:thaiti), looks(:quimper)])
    
    get :index, format: :json

    assert_response :success
    assert_equal 6, json_response["flinkers"].count
  end
  
end
