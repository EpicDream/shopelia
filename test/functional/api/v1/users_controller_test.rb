require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users

  setup do
    @user = users(:elarch)
    sign_in @user
  end

  test "it should show user" do
    get :show, id: @user, format: :json
    assert_response :success
  end

  test "it should update user" do
    put :update, id: @user, user: { first_name: "Peter" }, format: :json
    assert_response 204
  end

  test "it should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user, format: :json
    end

    assert_response 204
  end
end

