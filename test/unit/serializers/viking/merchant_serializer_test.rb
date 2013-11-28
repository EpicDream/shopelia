# -*- encoding : utf-8 -*-
require 'test_helper'

class Viking::MerchantSerializerTest < ActiveSupport::TestCase
  
  setup do
    @merchant = merchants(:amazon)
  end
  
  test "it should correctly serialize viking merchant" do
    merchant_serializer = Viking::MerchantSerializer.new(@merchant)
    hash = merchant_serializer.as_json
      
    assert_equal @merchant.id, hash[:merchant][:id]
    assert_equal @merchant.mapping_id, hash[:merchant][:mapping_id]

    @merchant.update_attribute :mapping_id, nil
    merchant_serializer = Viking::MerchantSerializer.new(@merchant)
    hash = merchant_serializer.as_json
      
    assert_equal @merchant.id, hash[:merchant][:id]
    assert hash[:merchant][:mapping_id].nil?
  end

end

