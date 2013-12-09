require 'test_helper'

class Api::Flink::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:elarch)
    @token = "CAAKcj4ETCX4BAN4RSgpT73WjZBU3HZAj8Ub3BVNlQosUUybYV4iDvbeHTXkkwQCxwqvidsNyFVUHazIZCLQytY8quxVwznZBKKHjHEC9fbfZAhqtHP0fvtJWdlmXKY3EsvU0KibTh4K5tYAb9Eokuzeb5PLJxP0BxJygrIJZC46pEdPK68sLreB5HddVuP1a0ZD"
  end

  test "it should login flinker with email and password" do
    post :create, email: @flinker.email, password: "tototo", format: :json
    assert_response :success

    assert json_response["auth_token"], "Auth token must be sent back"
    assert_equal @flinker.reload.authentication_token, json_response["auth_token"]
  end

  test "it should send an error when facebook token is invalid" do
    assert_difference(['Flinker.count'],0) do
      post :create, provider: "facebook", token: "tototo", format: :json
    end
    assert_response :unauthorized
    assert_equal "facebook token is invalid", json_response["error"]
  end

  test "it should create a flinker with facebook token" do
    assert_difference(['Flinker.count']) do
      post :create, provider: "facebook", token: @token, format: :json
    end
    assert_response :success
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
  end

  test "it should merge flinker account with facebook token when email already exists" do
    flinker = Flinker.create!(email: "bellakra@eleves.enpc.fr",password: "tototo",password_confirmation:"tototo")
    assert_difference(['Flinker.count'],0) do
      post :create, provider: "facebook", token: @token, format: :json
    end
    assert_response :success
    assert json_response["auth_token"], "Auth token must be sent back"
    assert_equal flinker.reload.authentication_token, json_response["auth_token"]
    flinker_auth = FlinkerAuthentication.where(flinker_id: flinker.id).first
    assert_equal flinker_auth.uid, "693006605"
  end

  test "it should sign in flinker without creating a new one if he already exists" do
    post :create, provider: "facebook", token: @token, format: :json
    assert_difference(['Flinker.count'],0) do
      post :create, provider: "facebook", token: @token, format: :json
    end
    assert_response :success
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
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

