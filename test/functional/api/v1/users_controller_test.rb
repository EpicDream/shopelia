require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase
  fixtures :users

  setup do
    @user = users(:elarch)
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { 
        email: "user@gmail.com", 
        password: "password", 
        password_confirmation: "password",
        first_name: "John",
        last_name: "Doe" }
    end

    assert_response 201
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

