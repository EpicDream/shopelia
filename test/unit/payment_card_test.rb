require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase

  test "it should create a payment card" do
    card = PaymentCard.new(
      :user_id => users(:elarch).id,
      :number => "4970100000000154",
      :exp_month => "02",
      :exp_year => "2017",
      :cvv => "123")
    assert card.save, card.errors.full_messages.join(",")

    connection = ActiveRecord::Base.connection
    result = ActiveRecord::Base.connection.execute("select number, cvv from payment_cards where id = #{card.id}")
    card_data = result[0]
    assert_equal("4XXXXXXXXXXX0154", card_data[0])
    assert_equal('XXX', card_data[1])

    reload_card = PaymentCard.find(card.id)
    assert_equal("4970100000000154", reload_card.number)
    assert_equal("123", reload_card.cvv)
    assert_equal("02", reload_card.exp_month)
    assert_equal("2017", reload_card.exp_year)
  end

  test "it should not load a card with corrupted data" do
    card = payment_cards(:elarch_hsbc)
    ActiveRecord::Base.connection.execute("update payment_cards set exp_month = '12' where id = #{card.id}")
    assert_raises(ArgumentError) { PaymentCard.find(card.id) }
  end

  test "it should not create a payment card with invalid data" do
    card = PaymentCard.new(
      :user_id => users(:elarch).id,
      :number => "497010XXX0000154",
      :exp_month => "02",
      :exp_year => "2017",
      :cvv => "1X3")
   
    assert(!card.save)
    assert(card.errors.size == 2)
  end
  
  test "it should not update a payment card with invalid data" do
    card = payment_cards(:manu_hsbc)
    card.number = '4970100000X00154'
    assert(!card.save)
    assert(card.errors.size == 1)
  end
  
  test "it should fail all non completed orders attached to a destroyed payment card" do
    order = orders(:elarch_rueducommerce_billing)
    assert_equal :billing, order.state
    order.meta_order.payment_card.destroy
    
    assert_equal :failed, order.reload.state
    assert_equal "user", order.error_code
    assert_equal "payment_card_destroyed", order.message
  end

  test "it shouldn't fail a completed orders attached to a destroyed payment card" do
    order = orders(:elarch_rueducommerce_billing)
    order.update_attribute :state_name, "completed"
    order.meta_order.payment_card.destroy
    
    assert_equal :completed, order.reload.state
  end

  test "it should create mangopay card" do
    card = payment_cards(:elarch_hsbc)
    result = card.create_mangopay_card

    assert_equal "success", result[:status], result[:message]
    assert card.mangopay_id.present?
  end

end
