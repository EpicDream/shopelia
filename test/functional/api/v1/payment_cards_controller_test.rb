require 'test_helper'

class Api::V1::PaymentCardsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :payment_cards

  setup do
    @user = users(:elarch)
    sign_in @user
    @card = payment_cards(:elarch_hsbc)
  end

  test "it should create payment card" do
    assert_difference('PaymentCard.count', 1) do
      post :create, payment_card: {
        :user_id => users(:elarch).id,
        :number => "1234123412341234",
        :exp_month => "02",
        :exp_year => "2015",
        :cvv => "123" }, format: :json
    end
    
    assert_response :success
  end

  test "it should show payment cartd" do
    get :show, id: @card, format: :json
    assert_response :success
  end

  test "it should get all payment cards for user" do
    get :index, format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of cards"
    assert_equal 1, json_response.count
  end

  test "it should destroy payment card" do
    assert_difference('PaymentCard.count', -1) do
      delete :destroy, id: @card, format: :json
    end

    assert_response 204
  end
  
  test "it should fail bad card creation" do
    post :create, payment_card:{}, format: :json
    assert_response 422
  end
  
end

