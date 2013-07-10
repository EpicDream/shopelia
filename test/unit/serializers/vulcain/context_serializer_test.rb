# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::ContextSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants, :users, :payment_cards, :merchant_accounts, :order_items, :addresses
  
  setup do
    @order = orders(:elarch_rueducommerce)
  end
  
  test "it should correctly serialize context" do
    order_serializer = Vulcain::ContextSerializer.new(@order)
    context = order_serializer.as_json[:context]

    assert context[:account].present?
    assert context[:session].present?
    assert context[:order].present?
    assert context[:order][:credentials][:number].present?
    assert context[:user].present?

    session = context[:session]
    assert_equal @order.uuid, session[:uuid]
    assert_equal @order.callback_url, session[:callback_url]
    
    order = context[:order]
    assert_equal 2, order[:products_urls].count
  end

  test "it should correctly serialize context when answering" do
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
    @order.update_attributes(
      :cvd_solution => "amazon",
      :mangopay_amazon_voucher_code => "JTUJ-SC5P4S-6N3F"
    )
    order_serializer = Vulcain::ContextSerializer.new(@order)
    context = order_serializer.as_json[:context]
    assert_equal "JTUJ-SC5P4S-6N3F", context[:order][:credentials][:voucher]
  end

end
