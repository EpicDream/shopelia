# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::ContextSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants, :users, :payment_cards, :merchant_accounts, :order_items
  
  setup do
    @order = orders(:elarch_rueducommerce)
  end
  
  test "it should correctly serialize context" do
    order_serializer = Vulcain::ContextSerializer.new(@order)
    context = order_serializer.as_json[:context]

    assert context[:account].present?
    assert context[:session].present?
    assert context[:order].present?
    assert context[:user].present?

    session = context[:session]
    assert_equal @order.uuid, session[:uuid]
    assert_equal @order.callback_url, session[:callback_url]
    
    order = context[:order]
    assert_equal 2, order[:products_urls].count
  end

end
