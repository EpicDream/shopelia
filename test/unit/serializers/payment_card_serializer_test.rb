# -*- encoding : utf-8 -*-
require 'test_helper'

class PaymentCardSerializerTest < ActiveSupport::TestCase
  fixtures :users, :payment_cards
  
  setup do
    @card = payment_cards(:elarch_hsbc)
  end
  
  test "it should correctly serialize payment card" do
    card_serializer = PaymentCardSerializer.new(@card)
    hash = card_serializer.as_json
    
    assert_equal 5, hash[:payment_card].count
    assert_equal @card.id, hash[:payment_card][:id]
    assert_equal @card.name, hash[:payment_card][:name]
    assert_equal @card.number, hash[:payment_card][:number]
    assert_equal @card.exp_month, hash[:payment_card][:exp_month]
    assert_equal @card.exp_year, hash[:payment_card][:exp_year]
  end

end

