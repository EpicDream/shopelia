require 'test_helper'

class MetaOrderTest < ActiveSupport::TestCase

  setup do
    @meta = meta_orders(:elarch_billing)
  end

  test "it should create meta order" do 
    meta = MetaOrder.new(
      user_id:users(:elarch).id,
      address_id:addresses(:elarch_neuilly).id,
      payment_card_id:payment_cards(:elarch_hsbc).id)
    assert meta.save, meta.errors.full_messages.join(",")
  end

  test "it shouldn't create meta order without address" do 
    meta = MetaOrder.new(
      user_id:users(:elarch).id,
      payment_card_id:payment_cards(:elarch_hsbc).id)
    assert !meta.save
  end

  test "it shouldn't create meta order without payment card" do 
    meta = MetaOrder.new(
      user_id:users(:elarch).id,
      address_id:addresses(:elarch_neuilly).id)
    assert !meta.save
  end

  test "it should set billed amount" do
    b = BillingTransaction.create!(meta_order_id:@meta.id)
    b.update_attribute :success, false
    b = BillingTransaction.create!(meta_order_id:@meta.id,amount:1000)
    b.update_attribute :success, true
    BillingTransaction.create!(meta_order_id:@meta.id,amount:1000)

    assert_equal 2000, @meta.billed_amount
  end

  test "it shouldn't create mangopay wallet if billing solution is not mangopay" do
    @meta.update_attribute :billing_solution, "be2bill"
    result = @meta.create_mangopay_wallet

    assert_equal "error", result[:status]
    assert_equal "billing solution must be mangopay", result[:message]
  end

  test "it should create mangopay wallet" do
    @meta.update_attribute :billing_solution, "mangopay"
    result = @meta.create_mangopay_wallet

    assert_equal "created", result[:status]
    assert @meta.mangopay_wallet_id.present?

    id = @meta.mangopay_wallet_id
    result = @meta.create_mangopay_wallet

    assert_equal "error", result[:status]
    assert_equal "wallet already exists", result[:message]
    assert_equal id, @meta.mangopay_wallet_id
  end
end
