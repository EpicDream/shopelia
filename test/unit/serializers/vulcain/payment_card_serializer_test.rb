# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::PaymentCardSerializerTest < ActiveSupport::TestCase
  fixtures :users, :payment_cards
  
  setup do
    @card = payment_cards(:elarch_hsbc)
  end
  
  test "it should correctly serialize payment card" do
    card_serializer = Vulcain::PaymentCardSerializer.new(@card)
    hash = card_serializer.as_json
    
    assert_equal "Eric Larcheveque", hash[:payment_card][:holder]
    assert_equal "4970100000000154", hash[:payment_card][:number]
    assert_equal "2", hash[:payment_card][:exp_month]
    assert_equal "2015", hash[:payment_card][:exp_year]
    assert_equal "123", hash[:payment_card][:cvv]
  end

end

