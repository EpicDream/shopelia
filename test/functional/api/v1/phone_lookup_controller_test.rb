require 'test_helper'

class Api::V1::PhoneLookupControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should lookup number" do
    get :show, id: "0959497434", format: :json

    assert_response :success
    assert_equal 5, json_response.size
  end
end