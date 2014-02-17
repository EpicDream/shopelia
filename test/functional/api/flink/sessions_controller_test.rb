require 'test_helper'

class Api::Flink::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:elarch)
    @fanny = flinker_authentications(:fanny)
  end

  test "login flinker with valid email and password" do
    post :create, email: @flinker.email, password: "tototo", format: :json
    assert_response :success

    assert json_response["auth_token"], "Auth token must be sent back"
    assert_equal @flinker.reload.authentication_token, json_response["auth_token"]
  end

  test "login a flinker with a blank password is unauthorized" do
    post :create, email: @flinker.email, password: "", format: :json
  
    assert_response :unauthorized
  end
  
  test "login when bad email or password return unauthorized with error description" do
    post :create, email: @flinker.email, password: "invalid", format: :json
    
    assert_response :unauthorized
    assert_equal I18n.t('devise.failure.invalid'), json_response["error"]
  end

  test "facebook token must be valid to fetch or create flinker" do
    assert_no_difference('Flinker.count') do
      post :create, provider: "facebook", token: "tototo", format: :json
    end
    
    assert_response :unauthorized
    assert_equal "Facebook token is invalid", json_response["error"]
  end
  
  test "create flinker from facebook" do
    flinkers(:fanny).destroy
    token = @fanny.token and @fanny.destroy
    
    assert_difference(['Flinker.count']) do
      post :create, provider: "facebook", token: token, format: :json
    end

    assert_response :success
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
    assert_equal "Fanny Louvel", json_response["flinker"]["name"]
  end
  
  test "sign existing flinker without creating new one" do
    flinkers(:fanny).destroy

    assert_difference('Flinker.count', 1) do
      1.upto(2) {
        post :create, provider: "facebook", token: @fanny.token, format: :json
      }
    end

    assert_response :success
    assert json_response["auth_token"].present?
    assert_equal "fanny.louvel@wanadoo.fr", json_response["flinker"]["email"]
    assert_equal "Fanny Louvel", json_response["flinker"]["name"]
  end
  
  test "logout flinker" do
    sign_in @flinker
    token = @flinker.authentication_token

    post :destroy, email: @flinker.email, format: :json
    assert_response :success
  
    assert_not_equal token, @flinker.reload.authentication_token, "Auth token must have changed after logout"
  end
  
  test "it should fail logout with incorrect email address" do
    sign_in @flinker
    post :destroy, email: "invalid@death.com", format: :json
  
    assert_response :unauthorized
  end
  
  test "update flinker auth provider token and avatar if none" do
    sign_in flinkers(:fanny)
    token  = @fanny.token
    assert @fanny.update_attributes(token:"oldtoken", flinker_id:flinkers(:fanny).id)

    put :update, provider: "facebook", token: token, format: :json
    
    assert_response :success
    assert_equal token, @fanny.reload.token
    assert_not_match(/missing/, flinkers(:fanny).reload.avatar.url)
  end
  
  test "assign country on update if none(this is temp feature to retrieve countries)" do
    @request.env["X-Flink-Country-Iso"] = "ES"
    sign_in flinkers(:fanny)
    @fanny.update_attributes(flinker_id:flinkers(:fanny).id)
    
    put :update, provider: "facebook", token: @fanny.token, format: :json
    
    assert_response :success
    assert_equal "ES", json_response["flinker"]["country"]
    assert_equal countries(:spain), flinkers(:fanny).reload.country
  end

end

