require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users, :psps, :psp_users

  test "it should create payment card localy and remotely, then destroy it" do
    VCR.use_cassette('card') do    
      card = PaymentCard.create(
        :user_id => users(:elarch).id,
        :number => "4970100000000154",
        :exp_month => "02",
        :exp_year => "2017",
        :cvv => "123")
      assert card.persisted?, card.errors.full_messages.join(",")
      
      card.create_leetchi
      assert card.leetchi, "Leetchi payment card not created"

      remote_payment_card_id = card.leetchi.remote_payment_card_id
      assert_difference(['PaymentCard.count', 'PspPaymentCard.count'], -1) do
        card.destroy
        assert card.destroyed?, card.errors.full_messages.join(",")
      end
    end
  end
  
  test "it should manage leetchi API failure when creating payment card" do
    VCR.use_cassette('card_fail') do
      card = PaymentCard.create(
        :user_id => users(:manu).id,
        :number => "4970100000000154",
        :exp_month => "02",
        :exp_year => "2017",
        :cvv => "123")
      assert card.persisted?, card.errors.full_messages.join(",")
      
      result = card.create_leetchi
      assert !card.leetchi.present?, "Leetchi payment card should not have been created"
      
      errors = JSON.parse(result)
      assert_equal "remote", errors["origin"]
      assert_equal 0, errors["error_code"]
      assert_equal "The UserProfile #123 of partner 'prixing' is not found.", errors["user_message"]
      assert_equal "The UserProfile #123 of partner 'prixing' is not found.", errors["message"]
      assert_equal "UserError", errors["type"]
    end    
  end
  
end
