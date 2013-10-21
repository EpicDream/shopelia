# -*- encoding : utf-8 -*-
require 'test_helper'

class Customers::CadeauShakerTest < ActiveSupport::TestCase

  setup do
    content = <<__END
<?xml version="1.0" encoding="UTF-8"?>
<commandes>
  <commande>
    <id_commande>1001</id_commande>
    <product_version_id>1245</product_version_id>
    <quantity>1</quantity>
    <first_name>Ludovic</first_name>
    <last_name>JOUILLEROT</last_name>
    <address>12 rue de la Fontenotte</address>
    <address2>.</address2>
    <telephone>0668239001</telephone>
    <zip>57070</zip>
    <city>METZ</city>
    <country_iso>fr</country_iso>
    <expected_price_total>34</expected_price_total>
    <gift_message>Message</gift_message>
  </commande>
  <commande>
    <id_commande>991</id_commande>
    <product_version_id>112988</product_version_id>
    <quantity>1</quantity>
    <first_name>Laura</first_name>
    <last_name>CHANELIERE</last_name>
    <address>19 rue béraud</address>
    <address2>Batiment E</address2>
    <telephone>0662198344</telephone>
    <zip>42100</zip>
    <city>saint etienne</city>
    <country_iso>fr</country_iso>
    <expected_price_total>18</expected_price_total>
    <gift_message>Message</gift_message>
  </commande>
</commandes>
__END
    @customer = Customers::CadeauShaker.new
    @orders = @customer.extract_orders(content)
    @product = product_versions(:dvd)
    @user = users(:cadeau_shaker)
    @developer = developers(:cadeau_shaker)
    @order = @orders[0]
    @order["product_version_id"] = @product.id
  end

  test "it extract orders from XML" do
    assert_equal 2, @orders.count
    assert_equal "1001", @orders[0]["id_commande"]
  end
  
  test "it should build order uuid" do
    assert_equal 32, @customer.build_uuid(1001).length
    assert_equal "cadeaushaker1001xxxxxxxxxxxxxxxx", @customer.build_uuid(1001)
    assert_equal "cadeaushaker100999xxxxxxxxxxxxxx", @customer.build_uuid(100999)
  end
  
  test "it should build address" do
    address = @customer.build_address(@orders[0])
    assert address.errors.empty?, address.errors.full_messages.join(",")
    assert_equal "Ludovic", address.first_name
    assert_equal "JOUILLEROT", address.last_name
    assert_equal "12 rue de la Fontenotte", address.address1
    assert address.address2.nil?
    assert_equal "57070", address.zip
    assert_equal "METZ", address.city
    assert_equal "0668239001", address.phone
    assert_equal "France", address.country.name
  end
  
  test "it should fail bad address" do
    @order["address"] = nil
    address = @customer.build_address(@orders[0])
    assert address.errors.any?
  end  
  
  test "it shouldn't process order without first_name" do
    @order["first_name"] = nil
    log = @customer.process_order(@order)
    assert_match /^Missing name/, log
  end

  test "it shouldn't process order without last_name" do
    @order["last_name"] = nil
    log = @customer.process_order(@order)
    assert_match /^Missing name/, log
  end

  test "it shouldn't process order with invalid address" do
    @order["address"] = nil
    log = @customer.process_order(@order)
    assert_match /^Invalid address/, log
  end

  test "it shouldn't process order for non French address" do
    @order["country_iso"] = "be"
    log = @customer.process_order(@order)
    assert_match /^Only French/, log
  end

  test "it shouldn't process order if product version not found" do
    @order["product_version_id"] = 0
    log = @customer.process_order(@order)
    assert_match /^Impossible to find/, log
  end

  test "it shouldn't process order without valid expected price total" do
    @order["expected_price_total"] = nil
    log = @customer.process_order(@order)
    assert_match /^Invalid expected price total/, log
  end

  test "it shouldn't process order without gift message" do
    @order["gift_message"] = nil
    log = @customer.process_order(@order)
    assert_match /^Gift message required/, log
  end
    
  test "it shouldn't process order if already existing uuid" do
    Order.first.update_attribute :uuid, @customer.build_uuid(@order["id_commande"])
    assert_difference "Order.count", 0 do
      log = @customer.process_order(@order)
      assert log.blank?
    end
  end
  
  test "it should process order for queue" do
    assert_difference "Order.count", 1 do
      log = @customer.process_order(@order)
      assert_match /successfully queued for processing/, log
    end
    order = Order.find_by_uuid(@customer.build_uuid(@order["id_commande"]))
    assert order.present?
    assert_equal @developer.id, order.developer_id
    assert_equal @user.id, order.user_id
    assert_equal "queued", order.state_name
    assert_equal "batch", order.tracker
    assert_equal "Message", order.gift_message
    assert_equal payment_cards(:cadeau_shaker).id, order.payment_card_id
    assert_equal 1, order.order_items.count
    assert_equal @product.id, order.order_items.first.product_version_id
    assert_equal @order["expected_price_total"].to_f, order.expected_price_total
  end  
end
