# -*- encoding : utf-8 -*-
require 'test_helper'

class Viking::MerchantSerializerTest < ActiveSupport::TestCase
  fixtures :merchants
  
  setup do
    @merchant = merchants(:amazon)
  end
  
  test "it should correctly serialize merchant" do
    merchant_serializer = Viking::MerchantSerializer.new(@merchant)
    hash = merchant_serializer.as_json
      
    assert_equal @merchant.id, hash[:product][:id]
    assert_equal @merchant.viking_data, hash[:product][:data]
  end

end

