require 'test_helper'

class PspPaymentCardTest < ActiveSupport::TestCase
  fixtures :payment_cards, :psps, :psp_payment_cards

  test "it should create psp payment card" do
    card = PspPaymentCard.new(
      :payment_card_id => payment_cards(:elarch_hsbc).id,
      :psp_id => psps(:tunz).id,
      :remote_payment_card_id => 123)
    assert card.save
  end
  
  test "it should have unicity of payment cards for a psp" do
    card = PspPaymentCard.new(
      :payment_card_id => payment_cards(:elarch_hsbc).id,
      :psp_id => psps(:leetchi).id,
      :remote_payment_card_id => 123)
    assert !card.save
  end

  test "it should have unicity of object_id for a psp" do
    card = PspPaymentCard.new(
      :payment_card_id => payment_cards(:manu_hsbc).id,
      :psp_id => psps(:leetchi).id,
      :remote_payment_card_id => psp_payment_cards(:elarch_leetchi_hsbc).remote_payment_card_id)
    assert !card.save
  end

end
