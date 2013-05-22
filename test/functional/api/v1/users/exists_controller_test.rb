require 'test_helper'

class Api::V1::Users::ExistsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users

  test "user exists" do
    post :create, data:{email:"elarch@gmail.com"}, format: :json
    assert_response :success
  end

  test "user doesn't exist" do
    post :create, data:{email:"nope@nope.nope"}, format: :json
    assert_response :not_found
  end
  
  test "bad request" do
    post :create, {}, format: :json
    assert_response :unprocessable_entity
  end

end

