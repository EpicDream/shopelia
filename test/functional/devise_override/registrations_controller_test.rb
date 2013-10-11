require 'test_helper'

class DeviseOverride::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test "it should sign up user" do
    post :create, user:{email:"elarch-test@gmail.com",password:"tototo",first_name:"Eric",last_name:"Larch"}

    assert warden.authenticated?(:user)
    assert_redirected_to home_index_path
  end

  test "it should fail sign up of user" do
    post :create, user:{email:"elarch-test@gmail.com",password:"prout"}

    assert !warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test "it should fail sign up of user with blank password" do
    post :create, user:{email:"elarch-test@gmail.com",password:""}

    assert !warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test "it should fail sign up of user with blank name" do
    post :create, user:{email:"elarch-test@gmail.com",password:"merguez"}

    assert !warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test "it should sign up user in Ajax" do
    xhr :post, :create, user:{email:"elarch-test@gmail.com",password:"tototo",first_name:"Eric",last_name:"Larch"}

    assert warden.authenticated?(:user)
    assert_template "devise/registrations/success"
  end

  test "it should fail sign up of user in Ajax" do
    xhr :post, :create, user:{email:"elarch-test@gmail.com",password:"prout"}

    assert !warden.authenticated?(:user)
    assert_template "devise/registrations/error"
  end  
end