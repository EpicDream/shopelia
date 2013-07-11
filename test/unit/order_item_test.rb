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
  
  test "it should truncate product title to 250 characteres" do
    @item.product_title = "0" * 500
    assert @item.save
    
    assert_equal 250, @item.product_title.length
  end
  
end
