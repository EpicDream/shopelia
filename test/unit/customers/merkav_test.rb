# -*- encoding : utf-8 -*-
require 'test_helper'

class Customers::MerkavTest < ActiveSupport::TestCase

  setup do
    @developer = developers(:merkav)
    Customers::Merkav.set_quota(500)
    @transaction = MerkavTransaction.create!(amount:100,vad_id:53)
  end

  test "it should run good card" do
    setup_card("111")
    @merkav = Customers::Merkav.new(@transaction)

    @merkav.generate_customer_data

    assert_not_nil @transaction.reload.token
    assert_not_nil @transaction.reload.optkey

    @merkav.generate_transaction

    assert_not_nil @transaction.merkav_transaction_id
    assert_not_nil @transaction.executed_at
    assert_equal "success", @transaction.status
  end

  test "it should fail bad card" do
    setup_card("222")
    @merkav = Customers::Merkav.new(@transaction)

    @merkav.generate_customer_data
    @merkav.generate_transaction

    assert_not_nil @transaction.merkav_transaction_id
    assert_not_nil @transaction.executed_at
    assert_match /Dummy FAILED/, @transaction.status
  end

  test "it should fail error card" do
    setup_card("333")
    @merkav = Customers::Merkav.new(@transaction)

    @merkav.generate_customer_data
    @merkav.generate_transaction

    assert_not_nil @transaction.merkav_transaction_id
    assert_not_nil @transaction.executed_at
    assert_match /Dummy ERROR/, @transaction.status
  end

  private

  def setup_card cvv
    card = VirtualCard.new(amount:100,provider:"test")
    card.number = "5271190242643112"
    card.cvv = cvv
    card.exp_month = "12"
    card.exp_year = "2016"
    card.save
    @transaction.update_attribute :virtual_card_id, card.id
  end
end