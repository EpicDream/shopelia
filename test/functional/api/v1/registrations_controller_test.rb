require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should create user" do
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

end

