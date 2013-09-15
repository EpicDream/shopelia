require 'test_helper'

class PaymentTransactionVirtualisTest < ActiveSupport::TestCase

  setup do
    @meta = meta_orders(:elarch_billing)
    @order = orders(:elarch_rueducommerce_billing)
  end

  test "it shouldn't process amazon payment if meta order wallet doesn't exist" do
    @order.user.create_mangopay_user
    payment = PaymentTransaction.create(order_id:@order.id)
    result = payment.process

    assert_equal "error", result[:status]
    assert_equal "missing source mangopay wallet", result[:message]
  end    

  test "it shouldn't process virtualis payment if meta order wallet doesn't have enough money" do
    @meta.create_mangopay_wallet
    payment = PaymentTransaction.create(order_id:@order.id)
    result = payment.process

    assert_equal "error", result[:status]
    assert_match /enough money/, result[:message]
  end 

  test "it should process virtualis payment and generate cvd" do
    @meta.create_mangopay_wallet
    billing = BillingTransaction.create!(meta_order_id:@meta.id)
    result = billing.process

    assert_equal "processed", result[:status], result[:message]
    assert billing.success

    payment = PaymentTransaction.create(order_id:@order.id)
    assert_equal "virtualis", payment.processor
    assert_equal 1600, payment.amount
    assert_equal @meta.mangopay_wallet_id, payment.mangopay_source_wallet_id

    result = payment.process

    assert_equal "created", result[:status], result[:message]
    assert payment.virtual_card_id.present?
  end
end