require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  fixtures :orders, :products, :order_items

  setup do
    @order = orders(:elarch_rueducommerce)
    @product = products(:usbkey)
    @item = order_items(:item1)
  end
 
  test "it should create order item" do
    item = OrderItem.new(order:@order, product:@product)
    assert item.save
  end  
end
