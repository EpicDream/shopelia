# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::OrderSerializerTest < ActiveSupport::TestCase
  
  setup do
    @order = orders(:elarch_rueducommerce)
  end
  
  test "it should correctly serialize order" do
    order_serializer = Vulcain::OrderSerializer.new(@order)
    hash = order_serializer.as_json
      
    assert_equal @order.merchant.vendor, hash[:order][:vendor]
    assert hash[:order][:context].present?
  end

end
