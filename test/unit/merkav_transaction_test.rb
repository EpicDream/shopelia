require 'test_helper'

class MerkavTransactionTest < ActiveSupport::TestCase
  
  test "it should create merkav transaction" do
    assert MerkavTransaction.new(amount:100).save
  end

  test "it shouldn't create merkav transaction with invalid amount" do 
    assert !MerkavTransaction.new(amount:1).save
    assert !MerkavTransaction.new(amount:50000).save
  end

  test "it should generate CVV" do 
    transaction = MerkavTransaction.create(amount:100)
    assert_difference "VirtualCard.count" do 
      result = transaction.generate_virtual_card
      assert_equal "ok", result[:status]
    end
    assert_not_nil transaction.virtual_card_id
  end
end