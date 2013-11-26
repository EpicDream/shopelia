# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::VirtualCardSerializerTest < ActiveSupport::TestCase
  
  setup do
    @card = virtual_cards(:card)
  end
  
  test "it should correctly serialize virtual card" do
    card_serializer = Vulcain::VirtualCardSerializer.new(@card)
    hash = card_serializer.as_json
    
    assert_equal "Shopelia Virtualis", hash[:virtual_card][:holder]
    assert_equal "41111111111111111", hash[:virtual_card][:number]
    assert_equal "2", hash[:virtual_card][:exp_month]
    assert_equal "2015", hash[:virtual_card][:exp_year]
    assert_equal "123", hash[:virtual_card][:cvv]
  end
end