# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantSerializerTest < ActiveSupport::TestCase
  fixtures :merchants
  
  setup do
    @merchant = merchants(:rueducommerce)
  end
  
  test "it should correctly serialize merchant" do
    merchant_serializer = MerchantSerializer.new(@merchant)
    hash = merchant_serializer.as_json
      
    assert_equal @merchant.id, hash[:merchant][:id]
    assert_equal @merchant.name, hash[:merchant][:name]
    assert_equal @merchant.logo, hash[:merchant][:logo]
    assert_equal @merchant.url, hash[:merchant][:url]
  end

end

