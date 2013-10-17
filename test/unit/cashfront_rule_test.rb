require 'test_helper'

class CashfrontRuleTest < ActiveSupport::TestCase

  setup do
    @developer = developers(:prixing)
    @merchant = merchants(:rueducommerce)
    @rule = cashfront_rules(:amazon)
  end

  test "it should create cash front rule" do
    rule = CashfrontRule.new(
      merchant_id:@merchant.id,
      rebate_percentage:5,
      max_rebate_value:10)

    assert rule.save, rule.errors.full_messages.join(",")
    assert_equal 5, rule.rebate_percentage
    assert_equal 10, rule.max_rebate_value
  end

  test "it shouldn't create more than one rule for a scope" do
    # Merchant scope
    CashfrontRule.create!(
      merchant_id:@merchant.id,
      rebate_percentage:5,
      max_rebate_value:10)    
    rule = CashfrontRule.new(
      merchant_id:@merchant.id,
      rebate_percentage:5,
      max_rebate_value:10)
    assert !rule.save

    rule = CashfrontRule.new(
      merchant_id:merchants(:fnac).id,
      rebate_percentage:5,
      max_rebate_value:10)
    assert rule.save, rule.errors.full_messages.join(",")

    # Developer scope
    rule = CashfrontRule.new(
      merchant_id:@merchant.id,
      rebate_percentage:7,
      developer_id:@developer.id,
      max_rebate_value:10)
    assert rule.save

    rule = CashfrontRule.new(
      merchant_id:@merchant.id,
      rebate_percentage:7,
      developer_id:@developer.id,
      max_rebate_value:10)
    assert !rule.save

    rule = CashfrontRule.new(
      merchant_id:@merchant.id,
      rebate_percentage:7,
      developer_id:developers(:shopelia).id,
      max_rebate_value:10)
    assert rule.save
  end

  test "it should compute cashfront value for a price" do
    assert_equal 3, @rule.rebate(100)
    assert_equal 10, @rule.rebate(5000)

    @rule.update_attribute :max_rebate_value, nil
    assert_equal 300, @rule.rebate(10000)    
  end
end
