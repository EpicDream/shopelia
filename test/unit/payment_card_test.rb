require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users, :payment_cards

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
    assert_raises(ArgumentError) { card.save }
  end
  
  test "it should not update a payment card with invalid data" do
    card = payment_cards(:manu_hsbc)
    card.number = '4970100000X00154'
    assert_raises(ArgumentError) { card.save }
  end
  
end
