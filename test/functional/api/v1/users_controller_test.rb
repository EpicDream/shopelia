require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users

  setup do
    @user = users(:elarch)
    @user.confirm!
    sign_in @user
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { first_name: "Peter" }
    assert_response 204
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_response 204
  end
end

