require 'test_helper'

class Api::Flink::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should register new flinker" do
    assert_difference(['Flinker.count']) do
      post :create, params, format: :json
    end

    assert_response 201
    assert json_response["auth_token"].present?
    assert json_response["flinker"].present?
  end

  test "it should fail bad flinker registration" do
    post :create, flinker:{}, format: :json
    assert_response 422
  end
  
  test "assign country to flinker from X header iso code send with each request" do
    @request.env["X-Flink-Country-Iso"] = "FR"
    post :create, params, format: :json
    
    assert_response 201
    assert_equal countries(:france), Flinker.last.country
  end
  
  test "assign country to autofollow top blogs of the flinker country or universals" do
    @request.env["X-Flink-Country-Iso"] = "FR"
    
    assert_difference "FlinkerFollow.count", 3 do
      post :create, params, format: :json
    end
  end
  
  test "iso country code from accept language header" do
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr;q=1, en;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5"
    
    assert_difference "FlinkerFollow.count", 3 do
      post :create, params, format: :json
    end
  end
  
  test "assign lang iso code to flinker" do
    @request.env["X-Flink-User-Language"] = "fr-FR"
    
    post :create, params, format: :json
    
    flinker = Flinker.last
    
    assert_equal "fr-FR", flinker.lang_iso
  end
  
  private
  
  def params
    { flinker: { email: "flinker@gmail.com", username: "totousername", password: "merguez", password_confirmation: "merguez"}}
  end

end

