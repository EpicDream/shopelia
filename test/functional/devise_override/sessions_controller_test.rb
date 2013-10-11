require 'test_helper'

class DeviseOverride::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env['devise.mapping'] = Devise.mappings[:user]
    @user = users(:elarch)
  end

  test "it should sign in user" do
    post :create, user:{email:"elarch@gmail.com",password:"tototo"}

    assert warden.authenticated?(:user)
    assert_redirected_to home_index_path
  end

  test "it should fail sign in of user" do
    post :create, user:{email:"elarch@gmail.com",password:"prout"}

    assert !warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test "it should sign in user in Ajax" do
    xhr :post, :create, user:{email:"elarch@gmail.com",password:"tototo"}

    assert warden.authenticated?(:user)
    assert_template "devise/sessions/authorized"
  end

  test "it should fail sign in of user in Ajax" do
    xhr :post, :create, user:{email:"elarch@gmail.com",password:"prout"}

    assert !warden.authenticated?(:user)
    assert_template "devise/sessions/unauthorized"
  end  
end