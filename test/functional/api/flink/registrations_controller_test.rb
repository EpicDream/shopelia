require 'test_helper'

class Api::Flink::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should register new flinker" do
    assert_difference(['Flinker.count']) do
      post :create, flinker: {
          email: "flinker@gmail.com",
          username: "totousername",
          password: "merguez",
          password_confirmation: "merguez",
      }, format: :json
    end

    assert_response 201
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
  end

  test "it should fail bad flinker registration" do
    post :create, flinker:{}, format: :json
    assert_response 422
  end

end

