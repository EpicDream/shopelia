# -*- encoding : utf-8 -*-
require 'test_helper'

class LeetchiTest < ActiveSupport::TestCase
  fixtures :users, :orders, :addresses, :payment_cards, :merchants, :merchant_accounts
  
  setup do
    @order = orders(:elarch_rueducommerce)
    allow_remote_api_calls    
  end

  test "it shouldn't bill if prepared price is not equal to expected price" do
    VCR.use_cassette('leetchi') do
      result = Leetchi.bill @order
      assert_equal "Order expected total price and prepared total price are not equal", result["Error"]
    end
  end

  test "it shouldn't bill if prepared price is not in range" do
    VCR.use_cassette('leetchi') do
      @order.prepared_price_total = 300
      result = Leetchi.bill @order
      assert_equal "Order billing value should be beetwen 5€ and 200€", result["Error"]
    end
  end
 
end

