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
    put :update, id: @user, user: { first_name: "Peter" }.to_json, format: :json
    assert_response 204
  end

  test "it should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user, format: :json
    end

    assert_response 204
  end
  
  test "it should fail bad user update" do
    put :update, id: @user, user: { email: "toto" }.to_json, format: :json
    assert_response 422
  end
  
  test "it should fail request if not logged in (json format)" do
    sign_out @user
    get :show, id: @user, format: :json
    assert_response :unauthorized
  end

  test "it should fail request if not logged in (html format)" do
    sign_out @user
    get :show, id: @user
    assert_response 302
  end  
  
  test "it should restrict access to api key" do
    ENV["API_KEY"] = nil
    get :show, id: @user, format: :json
    assert_response :unauthorized
    get :show, id: @user, api_key: "invalid", format: :json
    assert_response :unauthorized
    get :show, id: @user, api_key: developers(:prixing).api_key, format: :json
    assert_response :success
  end  
    
end

