# -*- encoding : utf-8 -*-
require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  
  test "user account creation and ordering process" do
    user = { 
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

    post "/api/users", user:user, format: :json
    assert_response :success
    
    assert json_response["user"]
    assert json_response["auth_token"]
    
    user = User.find_by_id(json_response["user"]["id"])
    auth_token = json_response["auth_token"]

    post "/api/orders", auth_token:auth_token, order: { 
      products: [ {
        url:"http://www.rueducommerce.fr/productA",
        name:"Product A",
        image_url:"http://www.rueducommerce.fr/logo.jpg"
      } ], 
      expected_price_total:100,
      address_id:user.addresses.first.id,
      payment_card_id:user.payment_cards.first.id }, format: :json

    assert json_response["order"]
  end

end

