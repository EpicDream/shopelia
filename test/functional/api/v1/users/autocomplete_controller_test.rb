require 'test_helper'

class Api::V1::Users::AutocompleteControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should match" do
    post :create, email:"elarch", format: :json
    assert_response :success
    assert_equal 1, json_response["emails"].size
  end

  test "it shouldn't match" do
    post :create, email:"elarc", format: :json
    assert_response :not_found
  end

  test "bad request" do
    post :create, toto:"", format: :json
    assert_response :unprocessable_entity
  end

end

