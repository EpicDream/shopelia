require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @user = users(:elarch)
  end

  test "it should login user with email and password" do
    post :create, email: @user.email, password: "tototo", format: :json
    assert_response :success
    
    assert json_response["auth_token"], "Auth token must be sent back"
    assert_equal @user.reload.authentication_token, json_response["auth_token"]
  end
  
  test "it shouldn't login a user with blank password" do
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1", developer_id:developers(:prixing).id)
    post :create, email: @user.email, password: "", format: :json
    
    assert_response :unauthorized
  end
  
  test "it should logout user" do
    sign_in @user
    token = @user.reload.authentication_token
    post :destroy, email: @user.email, format: :json
    assert_response :success
    
    assert_not_equal token, @user.reload.authentication_token, "Auth token must have changed after logout"
  end

  test "it should fail login when bad email or password" do
    post :create, email: @user.email, password: "invalid", format: :json
    assert_response :unauthorized

    assert_equal I18n.t('devise.failure.invalid'), json_response["error"]
  end

  test "it should fail logout with incorrect email address" do
    sign_in @user
    token = @user.reload.authentication_token
    post :destroy, email: "invalid", format: :json
    
    assert_response :unauthorized
  end

  test "it should set device with user after login" do
    device = devices(:web)
    @request.cookies['visitor'] = device.uuid
    post :create, email: @user.email, password: "tototo", format: :json

    assert_not_nil device.reload.user_id
  end  
end

