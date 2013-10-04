# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::ContextSerializerTest < ActiveSupport::TestCase
    
  test "it should correctly serialize context" do
    @order = orders(:elarch_rueducommerce)
    order_serializer = Vulcain::ContextSerializer.new(@order)
    context = order_serializer.as_json[:context]

    assert context[:account].present?
    assert context[:session].present?
    assert context[:order].present?
    assert context[:order][:credentials][:number].present?
    assert context[:order][:gift_message].present?
    assert context[:user].present?

    session = context[:session]
    assert_equal @order.uuid, session[:uuid]
    assert_equal @order.callback_url, session[:callback_url]
    
    order = context[:order]
    assert_equal 2, order[:products_urls].count
    assert_equal [Linker.monetize(products(:headphones).url), Linker.monetize(products(:usbkey).url)].to_set, order[:products_urls].to_set
    assert_equal 2, order[:products].count
    assert_equal [1, 1], order[:products].map{|e| e[:quantity]}
    assert_equal [Linker.monetize(products(:headphones).url), Linker.monetize(products(:usbkey).url)].to_set, order[:products].map{|e| e[:url]}.to_set
    assert_equal [product_versions(:headphones).id, product_versions(:usbkey).id].to_set, order[:products].map{|e| e[:product_version_id]}.to_set
  end

  test "it should correctly serialize context when answering" do
    @order = orders(:elarch_rueducommerce)
    @order.questions = [
      { "id" => "1",
        "text" => "Color?",
        "options" => [
          { "blue" => "Bleu" },
          { "red" => "Rouge" }
        ],
        "answer" => "red"
      }
    ]
    order_serializer = Vulcain::ContextSerializer.new(@order)
    context = order_serializer.as_json[:context]

    assert context[:session].present?
    assert context[:answers].present?

    session = context[:session]
    assert_equal @order.uuid, session[:uuid]
    
    assert_equal "red", context[:answers][0][:answer]
    assert_equal "1", context[:answers][0][:question_id]
  end
  
  test "it should send back amazon voucher" do
    @order = orders(:elarch_amazon_billing)
    order_serializer = Vulcain::ContextSerializer.new(@order.reload)
    context = order_serializer.as_json[:context]

    assert_not_nil context[:order][:credentials][:number]
    assert_nil context[:order][:gift_message]

    t = PaymentTransaction.create!(
      order_id:@order.id,
      mangopay_amazon_voucher_code:"JTUJ-SC5P4S-6N3F"
    )
    order_serializer = Vulcain::ContextSerializer.new(@order.reload)
    context = order_serializer.as_json[:context]

    assert_equal "JTUJ-SC5P4S-6N3F", context[:order][:credentials][:voucher]
  end

  test "it should send back virtualis cvd" do
    @order = orders(:elarch_rueducommerce_billing)
    t = PaymentTransaction.create(order_id:@order.id)
    t.update_attribute :virtual_card_id, virtual_cards(:card).id

    order_serializer = Vulcain::ContextSerializer.new(@order.reload)
    context = order_serializer.as_json[:context]

    assert_equal "41111111111111111", context[:order][:credentials][:number]
  end
end
