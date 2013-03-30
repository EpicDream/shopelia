require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users, :psps, :psp_users

  test "it should create payment card localy and remotely, and destroy it" do
    allow_remote_api_calls
    VCR.use_cassette('card') do    
      card = PaymentCard.create(
        :user_id => users(:elarch).id,
        :number => "4970100000000154",
        :exp_month => "02",
        :exp_year => "2017",
        :cvv => "123")
      assert card.persisted?, card.errors.full_messages.join(",")
      assert card.leetchi, "Leetchi payment card not created"
      
      assert_difference(['PaymentCard.count', 'PspPaymentCard.count'], -1) do
        card.destroy
        assert card.destroyed?, card.errors.full_messages.join(",")
      end

      # remote_payment_card_id = card.leetchi.remote_payment_card_id
      # assert_equal "", Leetchi::Card.details(remote_payment_card_id)
    end
  end
end
