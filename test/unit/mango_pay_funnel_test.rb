# -*- encoding : utf-8 -*-
require 'test_helper'

class MangoPayFunnelTest < ActiveSupport::TestCase
  fixtures :users, :orders, :addresses, :payment_cards, :merchants, :merchant_accounts
  
  setup do
    @order = orders(:elarch_rueducommerce)
    @order.update_attribute :state_name, "billing"
    @order.update_attribute :prepared_price_total, @order.expected_price_total    
    allow_remote_api_calls    
  end

  test "it shouldn't bill if prepared price is not equal to expected price" do
    VCR.use_cassette('mangopay') do
      @order.prepared_price_total = 100
      result = MangoPayFunnel.bill @order
      assert_equal "Order expected total price and prepared total price are not equal", result["Error"]
    end
  end

  test "it shouldn't bill if prepared price is not in range" do
    VCR.use_cassette('mangopay') do
      @order.prepared_price_total = 500
      @order.expected_price_total = 500
      result = MangoPayFunnel.bill @order
      assert_equal "Order billing value should be beetwen 5€ and 400€", result["Error"]
    end
  end

  test "it shouldn't bill if state of order is not billing" do
    VCR.use_cassette('mangopay') do
      @order.update_attribute :state_name, "pending"
      result = MangoPayFunnel.bill @order
      assert_equal "Order is not in billing state", result["Error"]
    end
  end
 
  test "it shouldn't bill if order has already a contribution attached" do
    VCR.use_cassette('mangopay') do
      @order.mangopay_contribution_id = 1
      result = MangoPayFunnel.bill @order
      assert_equal "Order has already been billed on MangoPay", result["Error"]
    end
  end
  
  test "it should bill order" do
    VCR.use_cassette('mangopay') do
      result = MangoPayFunnel.bill @order
      assert_equal "success", result["Status"]
      assert @order.reload.mangopay_contribution_id
      assert_equal @order.prepared_price_total, @order.mangopay_contribution_amount/100
      assert_equal "success", @order.mangopay_contribution_status
      assert_equal "Transaction approved", @order.mangopay_contribution_message
    end
  end
      
end

