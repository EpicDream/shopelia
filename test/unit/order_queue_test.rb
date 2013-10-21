# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderQueueTest < ActiveSupport::TestCase
  
  setup do 
    populate_queue
  end

  test "it should find orders in queue" do
    assert_equal 2, Order.queued.count
    Order.queued.first.start_from_queue
    assert_equal 1, Order.queued.count
  end

  test "it shouldn't add again already queued orders" do
    order = Order.find_by_uuid("batchxcadeaushaker1001xxxxxxxxxx")

    assert_difference "Order.count", 0 do
      populate_queue
    end

    order.update_attribute :state_name, "pending_agent"
    assert_difference "Order.count", 0 do
      populate_queue
    end

    order.update_attribute :state_name, "completed"
    assert_difference "Order.count", 0 do
      populate_queue
    end

    order.update_attribute :state_name, "failed"
    assert_difference "Order.count", 0 do
      populate_queue
    end
  end

  test "it should start order from queue state" do
    order = Order.find_by_uuid("batchxcadeaushaker1001xxxxxxxxxx")
    order.start_from_queue
    assert_equal :preparing, order.reload.state
  end

  test "it should set queue busy" do
    order = Order.find_by_uuid("batchxcadeaushaker1001xxxxxxxxxx")
    assert !order.queue_busy?

    order2 = Order.find_by_uuid("batchxcadeaushaker991xxxxxxxxxxx")
    assert !order.queue_busy?

    order.start_from_queue
    assert order.queue_busy?

    order.update_attribute :state_name, "pending_agent"
    assert !order.queue_busy?    

    order.update_attribute :state_name, "billing"
    assert order.queue_busy?    

    order.update_attribute :state_name, "completed"
    assert !order.queue_busy?    

    order.update_attribute :state_name, "querying"
    assert !order.queue_busy?    

    order.update_attribute :state_name, "failed"
    assert !order.queue_busy?    

    order.update_attribute :state_name, "refunded"
    assert !order.queue_busy?    
  end

  private

  def populate_queue
    content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<commandes>
  <commande>
    <id_commande>1001</id_commande>
    <product_version_id>#{product_versions(:dvd).id}</product_version_id>
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
    <product_version_id>#{product_versions(:headphones).id}</product_version_id>
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
</commandes>"
    @customer = Customers::CadeauShaker.new
    @customer.extract_orders(content).each do |order|
      @customer.process_order(order)
    end
  end
end