require 'test_helper'

class BillingTransactionTest < ActiveSupport::TestCase
  
  setup do
    @meta = meta_orders(:elarch_billing)
  end

  test "it should create and initialize billing transaction" do
    billing = BillingTransaction.new(meta_order_id:@meta.id)
    
    assert billing.save, billing.errors.full_messages.join(",")
    assert_equal users(:elarch).id, billing.user_id
    assert_equal (@meta.orders.map(&:prepared_price_total).sum*100).round, billing.amount
    assert_equal "mangopay", billing.processor
  end

  test "it should fail creation if orders are not all in billing state" do
    @meta.orders.first.update_attribute :state_name, "pending_agent"
    billing = BillingTransaction.new(meta_order_id:@meta.id)
    
    assert !billing.save
    assert_equal I18n.t('billing_transactions.errors.invalid_state'), billing.errors.full_messages.first
  end

  test "it should fail creation if orders prepared prices are not less or equal expected total price" do
    @meta.orders.first.update_attribute :expected_price_total, 5
    billing = BillingTransaction.new(meta_order_id:@meta.id)
    
    assert !billing.save
    assert_equal I18n.t('billing_transactions.errors.price_inconsistency'), billing.errors.full_messages.first
  end

  test "it should fail creation if orders prepared prices are not in range" do
    @meta.orders.first.update_attribute :prepared_price_total, 500
    @meta.orders.first.update_attribute :prepared_price_total, 500
    billing = BillingTransaction.new(meta_order_id:@meta.id)
    
    assert !billing.save
  end

  test "it should set amount to remainder" do
    b = BillingTransaction.create!(meta_order_id:@meta.id,amount:1000)
    b.update_attribute :success, true
    b = BillingTransaction.create!(meta_order_id:@meta.id)
    assert_equal b.amount, 1600
  end

  test "it should fail creation if there are already successful transactions bigger or equal of prepared_billing_total" do
    BillingTransaction.create!(meta_order_id:@meta.id)
    billing = BillingTransaction.new(meta_order_id:@meta.id,amount:1000)
    
    assert !billing.save
    assert_equal I18n.t('billing_transactions.errors.already_fulfilled'), billing.errors.full_messages.first
  end

  test "it shouldn't process billing if meta order doesn't have payment card" do
    @meta.update_attribute :payment_card_id, nil
    billing = BillingTransaction.create!(meta_order_id:@meta.id)
    result = billing.process

    assert_equal "error", result[:status]
    assert_equal "missing payment card", result[:message]
  end

  test "it should process billing for mangopay processor" do
    billing = BillingTransaction.create!(meta_order_id:@meta.id)
    result = billing.process

    assert_equal "processed", result[:status], result[:message]
    assert billing.success
    assert billing.mangopay_contribution_id.present?
    assert_equal billing.amount, billing.mangopay_contribution_amount
    assert_equal "Transaction approved", billing.mangopay_contribution_message
    assert_equal @meta.reload.mangopay_wallet_id, billing.mangopay_destination_wallet_id

    wallet = MangoPay::Wallet.details(@meta.mangopay_wallet_id)
    assert_equal billing.amount, wallet['Amount']

    result = billing.process
    assert_equal "error", result[:status]
    assert_equal "transaction already processed", result[:message]
  end

  test "it should create cashfront transaction" do
    billing = BillingTransaction.new(
      meta_order_id:@meta.id,
      processor:"cashfront")
    
    assert billing.save, billing.errors.full_messages.join(",")
    assert_equal "cashfront", billing.processor
    assert_equal 30, billing.amount

    billing = BillingTransaction.new(
      meta_order_id:@meta.id,
      processor:"cashfront")

    assert !billing.save
    assert_equal I18n.t('billing_transactions.errors.cashfront_already_exists'), billing.errors.full_messages.first
  end

end