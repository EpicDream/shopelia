require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should register new user" do
    assert_difference('User.count') do
      post :create, user: { 
        email: "user@gmail.com", 
        password: "password", 
        password_confirmation: "password",
        first_name: "John",
        last_name: "Doe" }, format: :json
    end

    assert_response 201
  end

  test "it should fail bad user registration" do
    post :create, user:{}, format: :json
    assert_response 422
  end

end

