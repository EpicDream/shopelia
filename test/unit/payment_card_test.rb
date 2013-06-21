require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users

  test "it should create payment card" do
    card = PaymentCard.new(
      :user_id => users(:elarch).id,
      :number => "4970100000000154",
      :exp_month => "02",
      :exp_year => "2017",
      :cvv => "123")
    assert card.save, card.errors.full_messages.join(",")
  end
  
end
