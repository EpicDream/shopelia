# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantSerializerTest < ActiveSupport::TestCase
  
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
    assert_equal @merchant.tc_url, hash[:merchant][:tc_url]
    assert_equal @merchant.domain, hash[:merchant][:domain]
    assert_equal 1, hash[:merchant][:accepting_orders]
    assert_equal 1, hash[:merchant][:allow_quantities]
    assert_equal 0, hash[:merchant][:saturn]
  end

  test "it should set saturn" do
    merchant_serializer = MerchantSerializer.new(merchants(:amazon))
    hash = merchant_serializer.as_json

    assert_equal 1, hash[:merchant][:saturn]
  end
end