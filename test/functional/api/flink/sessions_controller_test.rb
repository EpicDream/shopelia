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
    assert_equal "Token is invalid", json_response["error"]
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
    assert_equal "Nicolas Bigot", json_response["flinker"]["name"]
    assert_equal true, json_response["creation"]
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
    assert_equal "nicolasbigot@icloud.com", json_response["flinker"]["email"]
    assert_equal "Nicolas Bigot", json_response["flinker"]["name"]
    assert_equal false, json_response["creation"]
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
  
  test "update lang iso code" do
    fanny = flinkers(:fanny)
    @request.env["X-Flink-User-Language"] = "de_DE"
    sign_in fanny
    
    assert_equal 'fr_FR', fanny.lang_iso
    
    put :update, format: :json
    
    assert_response :success
    assert_equal 'de_DE', fanny.reload.lang_iso
  end
  
  test "destroy flinker devices after sign out" do
    fanny = flinkers(:fanny)
    sign_in fanny
    
    assert_equal 2, Device.of_flinker(fanny).count

    post :destroy, email: fanny.email, format: :json

    assert_response :success
    assert_equal 0, Device.of_flinker(fanny).count
  end
  
  test "update time zone" do
    fanny = flinkers(:fanny)
    @request.env["X-Flink-User-Timezone"] = "Europe/Paris"
    sign_in fanny
    
    assert_equal 'America/New_York', fanny.timezone
    
    put :update, format: :json
    
    assert_response :success
    assert_equal 'Europe/Paris', fanny.reload.timezone
  end
  
  test "twitter tokens must be valid to fetch or create flinker" do
    assert_no_difference('Flinker.count') do
      post :create, provider: "twitter", token: "token", token_secret:"secret", format: :json
    end
    
    assert_response :unauthorized
    assert_equal "Token is invalid", json_response["error"]
  end

  test "session from twitter" do
    @flinker = flinkers(:boop)
    @boop = flinker_authentications(:boop)
    flinkers(:boop).destroy
    token, token_secret = @boop.token, @boop.token_secret
    @boop.destroy
    
    assert_difference(['Flinker.count']) do
      post :create, provider: "twitter", token: token, token_secret: token_secret, email:'boop@flink.io', format: :json
    end

    assert_response :success
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
    assert_equal "Flink", json_response["flinker"]["name"]
    assert_equal true, json_response["creation"]
  end
  
  test "sign existing flinker from twitter without creating new one" do
    @boop = flinker_authentications(:boop)
    flinkers(:boop).destroy

    assert_difference('Flinker.count', 1) do
      1.upto(2) {
        post :create, provider: "twitter", token: @boop.token, token_secret:@boop.token_secret, format: :json
      }
    end

    assert_response :success
    assert json_response["auth_token"].present?
    assert_equal false, json_response["creation"]
  end
  
  test "update flinker twitter tokens and avatar if none" do
    sign_in flinkers(:boop)
    boop = flinker_authentications(:boop)
    token  = boop.token
    token_secret = boop.token_secret
    assert boop.update_attributes(token:"oldtoken", token_secret:"oldsecret", flinker_id:flinkers(:boop).id)

    put :update, provider: "twitter", token: token, token_secret: token_secret, format: :json
    
    boop.reload
    assert_response :success
    assert_equal token, boop.token
    assert_equal token_secret, boop.token_secret
    assert_not_match(/missing/, flinkers(:boop).reload.avatar.url)
  end
  
end

