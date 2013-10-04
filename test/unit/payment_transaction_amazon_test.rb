require 'test_helper'

class PaymentTransactionAmazonTest < ActiveSupport::TestCase

  setup do
    @meta = meta_orders(:elarch_billing)
    @order = orders(:elarch_amazon_billing)
  end

  test "it should create payment transaction" do
    @meta.create_mangopay_wallet
    payment = PaymentTransaction.new(order_id:@order.id)
    
    assert payment.save, payment.errors.full_messages.join(",")
    assert_equal "amazon", payment.processor
    assert_equal 1000, payment.amount
    assert_equal @meta.mangopay_wallet_id, payment.mangopay_source_wallet_id
  end

  test "it shouldn't process amazon payment if meta order wallet doesn't exist" do
    @order.user.create_mangopay_user
    payment = PaymentTransaction.create(order_id:@order.id)
    result = payment.process

    assert_equal "error", result[:status]
    assert_equal "missing source mangopay wallet", result[:message]
  end    

  test "it shouldn't process amazon payment if meta order wallet doesn't have enough money" do
    @meta.create_mangopay_wallet
    payment = PaymentTransaction.create(order_id:@order.id)
    result = payment.process

    assert_equal "error", result[:status]
    assert_match /enough money/, result[:message]
  end 

  test "it should process amazon payment" do
    @meta.create_mangopay_wallet
    billing = BillingTransaction.create!(meta_order_id:@meta.id)
    result = billing.process

    assert_equal "processed", result[:status], result[:message]
    assert billing.success

    payment = PaymentTransaction.create(order_id:@order.id)
    result = payment.process

    assert_equal "created", result[:status], result[:message]
    assert payment.mangopay_amazon_voucher_id.present?
    assert payment.mangopay_amazon_voucher_code.present?

    result = payment.process
    assert_equal "created", result[:status], result[:message]
  end

end
