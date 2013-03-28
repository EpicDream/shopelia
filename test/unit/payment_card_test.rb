require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users

  test "it should create payment card" do
    card = PaymentCard.new(
      :user_id => users(:elarch).id,
      :number => "1234123412341234",
      :exp_month => "02",
      :exp_year => "2015",
      :cvv => "123")
    
    assert card.save, card.errors.full_messages.join(",")
  end
end
