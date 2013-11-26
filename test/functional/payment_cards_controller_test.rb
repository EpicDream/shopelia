require 'test_helper'

class PaymentCardsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    @card = payment_cards(:elarch_hsbc)
    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_match /0154/, response.body
  end

  test "should show card" do
    get :show, id: @card.id
    assert_response :success
  end

  test "should create card via ajax" do

    assert_difference('PaymentCard.count') do
      xhr :post, :create, :payment_card => {
        :number => "5105105105105100",
        :exp_month => "02",
        :exp_year => "2015",
        :cvv => "123"
      }
    end
    
    assert_response :success
  end


  test "should destroy card" do
    assert_difference('PaymentCard.count', -1) do
      delete :destroy, id: @card.id
    end

    assert_redirected_to payment_cards_path
  end
  
  test "should destroy card via ajax" do
    assert_difference('PaymentCard.count', -1) do
      xhr :delete, :destroy, id: @card.id
    end
    
    assert_response :success
  end
end
