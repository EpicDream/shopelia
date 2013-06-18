require 'test_helper'

class PaymentCardTest < ActiveSupport::TestCase
  fixtures :users

  test "it should create payment card localy and remotely, then destroy it" do
    allow_remote_api_calls
    VCR.use_cassette('card') do    
      card = PaymentCard.new(
        :user_id => users(:elarch).id,
        :number => "4970100000000154",
        :exp_month => "02",
        :exp_year => "2017",
        :cvv => "123")
      assert card.save, card.errors.full_messages.join(",")
      assert card.leetchi_created?, "Leetchi payment card not created"

      assert_difference(['PaymentCard.count'], -1) do
        card.destroy
        assert card.destroyed?, card.errors.full_messages.join(",")
      end
    end
  end
  
  test "it should manage leetchi API failure when creating payment card" do
    allow_remote_api_calls
    VCR.use_cassette('card_fail') do
      card = PaymentCard.create(
        :user_id => users(:manu).id,
        :number => "4970100000000154",
        :exp_month => "02",
        :exp_year => "2017",
        :cvv => "123")
      assert card.persisted?, card.errors.full_messages.join(",")
      assert !card.leetchi_created?, "Leetchi payment card should not have been created"

      mail = ActionMailer::Base.deliveries.last
      assert mail.present?, "a critical alert email should have been sent"
    end    
  end
  
end
