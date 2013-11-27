require 'test_helper'

class MerkavTransactionTest < ActiveSupport::TestCase
  
  setup do
    Customers::Merkav::set_quota(100)
  end

  test "it should create merkav transaction" do
    transaction = MerkavTransaction.new(amount:100, vad_id:1)
    assert transaction.save
    assert_equal "pending", transaction.status
  end

  test "it shouldn't create merkav transaction with invalid amount" do 
    assert !MerkavTransaction.new(amount:1, vad_id:1).save
    assert !MerkavTransaction.new(amount:50000, vad_id:1).save
  end

  test "it shouldn't create merkav transaction without vad_id" do 
    assert !MerkavTransaction.new(amount:1).save
  end

  test "it should generate CVV" do 
    transaction = MerkavTransaction.create(amount:100)
    assert_difference "VirtualCard.count" do 
      result = transaction.generate_virtual_card
      assert_equal "ok", result[:status]
    end
    assert_not_nil transaction.virtual_card_id

    assert_difference "VirtualCard.count", 0 do 
      result = transaction.generate_virtual_card
      assert_equal "ok", result[:status]
    end
  end

  test "it should fail creation if quota is exceeded" do
    transaction = MerkavTransaction.create(amount:100, vad_id:1)
    transaction.update_attribute :status, 'success'

    transaction = MerkavTransaction.new(amount:100, vad_id:1)
    assert !transaction.save
    assert_match /contact administrator/, transaction.errors.full_messages.join(",")

    Customers::Merkav::add_quota(100)
    assert transaction.save
  end
end