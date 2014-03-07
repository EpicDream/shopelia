require 'test_helper'

class Api::Flink::TopFlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:fanny)
  end

  test "it should get publishing flinkers" do
    get :index, format: :json

    assert_response :success
    assert_equal 3, json_response["flinkers"].count
  end
  
end
