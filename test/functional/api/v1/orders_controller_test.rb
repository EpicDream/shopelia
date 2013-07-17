require 'test_helper'

class Api::V1::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :order_items, :merchant_accounts, :addresses, :payment_cards

  setup do
    @user = users(:elarch)
    sign_in @user
    @order = orders(:elarch_rueducommerce)
    @card = payment_cards(:elarch_hsbc)
    @address = addresses(:elarch_neuilly)
  end

  test "it should create order" do
    assert_difference('Order.count', 1) do
      post :create, order: { 
        expected_price_total:100, 
        payment_card_id:@card.id,
        address_id:@address.id,
        products: [ {
          url:"http://www.rueducommerce.fr/productA",
          name:"Product A",
          image_url:"http://www.rueducommerce.fr/logo.jpg"
        } ]
      }, format: :json
    end
    
    assert_response :success
    assert_equal "preparing", Order.last.state_name
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "an admin email should have been sent"
    assert_match /Rails Testing/, mail.decoded
  end

  test "it should show order" do
    get :show, id: @order.uuid, format: :json
    assert_response :success
  end

end

