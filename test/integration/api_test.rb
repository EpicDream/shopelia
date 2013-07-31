# -*- encoding : utf-8 -*-
require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
    
  setup do
    @user = { 
      email: "eric@shopelia.fr",
      first_name: "John",
      last_name: "Doe",
      addresses_attributes: [ {
        phone: "0646403619",
        address1: "21 rue d'Aboukir",
        zip: "75002",
        city: "Paris"
      } ],
      payment_cards_attributes: [ {
        number: "4970100000000154",
        exp_month: "02",
        exp_year: "2017",
        cvv: "123"
      } ]        
    }
  end
  
  test "user account creation and ordering process" do
    post "/api/users", user:@user, format: :json
    assert_response :success
    
    assert json_response["user"]
    assert json_response["auth_token"]
    
    user = User.find_by_id(json_response["user"]["id"])
    auth_token = json_response["auth_token"]
    assert_equal developers(:prixing).id, user.developer_id

    post "/api/orders", auth_token:auth_token, order: { 
      products: [ {
        url:"http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        name:"Papier normal Fax T102 Brother FAXT102G1",
        image_url:"http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg"
      } ], 
      expected_price_total:60.13,
      address_id:user.addresses.first.id,
      payment_card_id:user.payment_cards.first.id }, format: :json

    assert json_response["order"]
    uuid = json_response["order"]["uuid"]
    assert uuid.present?
    
    order = Order.find_by_uuid(uuid)
    assert_equal :preparing, order.state
    
    product = order.order_items.first.product
    assert_equal "Papier normal Fax T102 Brother FAXT102G1", product.name
    assert_equal "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg", product.image_url
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO", product.url   
  end

  test "it shouldn't process order after a logout" do
    post "/api/users", user:@user, format: :json
    user = User.find_by_id(json_response["user"]["id"])

    post "/api/orders", order: { 
      products: [ {
        url:"http://www.rueducommerce.fr/productA",
        name:"Product A",
        image_url:"http://www.rueducommerce.fr/logo.jpg"
      } ], 
      expected_price_total:100,
      address_id:user.addresses.first.id,
      payment_card_id:user.payment_cards.first.id }, format: :json

    assert_response :unauthorized
  end
  
  test "it shouldn't create order if user's email is test@shopelia.fr" do
    @user["email"] = "test@shopelia.fr"
    post "/api/users", user:@user, format: :json
    user = User.find_by_id(json_response["user"]["id"])
    auth_token = json_response["auth_token"]

    assert_difference("Order.count", 0) do
      post "/api/orders", auth_token:auth_token, order: { 
        products: [ {
          url:"http://www.rueducommerce.fr/productA",
          name:"Product A",
          image_url:"http://www.rueducommerce.fr/logo.jpg"
        } ], 
        expected_price_total:100,
        address_id:user.addresses.first.id,
        payment_card_id:user.payment_cards.first.id }, format: :json

      assert_response :success
    end
  end
  
  test "it should register and complete an amazon order with user acceptation of new price" do
    # Create user
    post "/api/users", user:@user, format: :json
    assert_response :success
    
    assert json_response["user"]
    assert json_response["auth_token"]
    
    user = User.find_by_id(json_response["user"]["id"])
    auth_token = json_response["auth_token"]
    assert_equal developers(:prixing).id, user.developer_id

    # Create order
    post "/api/orders", auth_token:auth_token, order: { 
      products: [ {
        url:"http://www.amazon.fr/product_A",
        name:"Papier normal Fax T102 Brother FAXT102G1",
        image_url:"http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg"
      } ], 
      expected_price_total:10,
      address_id:user.addresses.first.id,
      payment_card_id:user.payment_cards.first.id }, format: :json

    assert json_response["order"]
    uuid = json_response["order"]["uuid"]
    assert uuid.present?
    
    order = Order.find_by_uuid(uuid)
    assert_equal :preparing, order.state
    assert_equal 10, order.expected_price_total
    assert_equal 10, order.expected_price_product
    assert_equal 0, order.expected_price_shipping
    
    item = order.order_items.first
    assert_equal 10, item.price
    
    # Assess order with higher price
    put "/api/callback/orders/#{order.uuid}", verb:"assess", content:{
      questions: [
        { id:1 }
      ],
      products: [
        { url:"http://www.amazon.fr/product_A",
          price: 50
        }
      ],
      billing: {
        shipping: 5,
        total: 55
      }
    }, format: :json
     
    assert_equal :querying, order.reload.state
    assert_equal 55, order.prepared_price_total
    assert_equal 50, order.prepared_price_product
    assert_equal 5, order.prepared_price_shipping
    assert_equal 50, item.reload.price
    
    # User confirm orders
    put "/orders/#{order.uuid}", order:{confirmation:"yes"}

    assert_equal :preparing, order.reload.state
    assert_equal 55, order.expected_price_total
    assert_equal 50, order.expected_price_product
    assert_equal 5, order.expected_price_shipping
    assert_equal 50, item.reload.price
    
    # Assess order with now correct price
    allow_remote_api_calls
    ENV["ALLOW_PAYLINE_DRIVER"] = "1"
    put "/api/callback/orders/#{order.uuid}", verb:"assess", content:{
      questions: [
        { id:1 }
      ],
      products: [
        { url:"http://www.amazon.fr/product_A",
          price: 50
        }
      ],
      billing: {
        shipping: 5,
        total: 55
      }
    }, format: :json

    assert_equal :preparing, order.reload.state
    
    assert order.mangopay_wallet_id.present?
    assert order.mangopay_contribution_id.present?
    assert_equal "success", order.mangopay_contribution_status
    assert_equal 5500, order.mangopay_contribution_amount
    assert order.mangopay_amazon_voucher_id.present?
    assert order.mangopay_amazon_voucher_code.present? 
    
    # Finalizing order
    put "/api/callback/orders/#{order.uuid}", verb:"success", content:{
      billing: {
        shipping: 5,
        total: 55,
        shipping_info: "info"
      }
    }, format: :json
    
    assert_equal :completed, order.reload.state
    
    assert_equal 50, order.billed_price_product
    assert_equal 5, order.billed_price_shipping
    assert_equal 55, order.billed_price_total    
  end  
  
end

