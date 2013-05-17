require 'test_helper'

class Api::V1::Users::VerifyControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :products, :merchant_accounts, :addresses, :payment_cards

  setup do
    @user = users(:elarch)
    sign_in @user
  end

  test "it should verify user" do
    post :create, data:{pincode:"1234"}, format: :json
    assert_response :success
  end

  test "it should fail user verification" do
    post :create, data:{pincode:"4567"}, format: :json
    assert_response :unauthorized
  end

end

