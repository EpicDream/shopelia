require 'test_helper'

class Api::Flink::FlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:elarch)
  end

  test "it should get publishing flinkers with looks" do
    get :index, format: :json
    assert_response :success
    
    assert_equal 4, json_response["flinkers"].count
  end
  
end
