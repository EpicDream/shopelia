# -*- encoding : utf-8 -*-
require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = { 
      email: "test@shopelia.fr",
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
    assert_equal :processing, order.state
    
    product = order.order_items.first.product
    assert_equal "Papier normal Fax T102 Brother FAXT102G1", product.name
    assert_equal "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg", product.image_url
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO", product.url   
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
  
end

