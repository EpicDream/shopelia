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
      
    assert_equal @merchant.id, hash[:merchant][:id]
    assert_equal JSON.parse(@merchant.viking_data), hash[:merchant][:data]
  end

end

