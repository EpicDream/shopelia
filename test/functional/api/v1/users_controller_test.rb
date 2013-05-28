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

  test "it should update user password" do
    put :update, id: @user, user: { current_password:"tototo", password:"tititi", password_confirmation:"tititi" }, format: :json
    assert_response 204
    assert @user.reload.valid_password?("tititi")
  end

  test "it shouldn't update user password with bad current password" do
    put :update, id: @user, user: { current_password:"badpassword", password:"tititi", password_confirmation:"tititi" }, format: :json
    assert_response 422
  end

  test "it should initialize password" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1")
    sign_in user
    put :update, id: user, user: { password:"tititi", password_confirmation:"tititi" }, format: :json
    assert_response 204
    assert user.reload.valid_password?("tititi")    
  end

  test "it should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user, password:"tototo", format: :json
    end

    assert_response 204
  end
  
  test "it should fail bad user update" do
    put :update, id: @user, user: { email: "toto" }, format: :json
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

=begin  
  test "it should restrict access to api key" do
    ENV['API_KEY'] = nil
    get :show, id: @user, format: :json
    assert_response :unauthorized
    @request.headers['X-Shopelia-ApiKey'] = 'invalid'
    get :show, id: @user, format: :json
    assert_response :unauthorized
    @request.headers['X-Shopelia-ApiKey'] = developers(:prixing).api_key
    get :show, id: @user, format: :json
    assert_response :success
  end  
=end
    
end

