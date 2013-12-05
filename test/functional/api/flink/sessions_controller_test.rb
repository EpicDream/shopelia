require 'test_helper'

class Api::Flink::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:elarch)
  end

  test "it should login flinker with email and password" do
    post :create, email: @flinker.email, password: "tototo", format: :json
    assert_response :success

    assert json_response["auth_token"], "Auth token must be sent back"
    assert_equal @flinker.reload.authentication_token, json_response["auth_token"]
  end

  test "it shouldn't login a flinker with blank password" do
    post :create, email: @flinker.email, password: "", format: :json

    assert_response :unauthorized
  end

  test "it should logout flinker" do
    sign_in @flinker
    token = @flinker.reload.authentication_token
    post :destroy, email: @flinker.email, format: :json
    assert_response :success

    assert_not_equal token, @flinker.reload.authentication_token, "Auth token must have changed after logout"
  end

  test "it should fail login when bad email or password" do
    post :create, email: @flinker.email, password: "invalid", format: :json
    assert_response :unauthorized

    assert_equal I18n.t('devise.failure.invalid'), json_response["error"]
  end

  test "it should fail logout with incorrect email address" do
    sign_in @flinker
    token = @flinker.reload.authentication_token
    post :destroy, email: "invalid", format: :json

    assert_response :unauthorized
  end

end

