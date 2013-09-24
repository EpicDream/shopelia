# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::AddressSerializerTest < ActiveSupport::TestCase
  
  setup do
    @address = addresses(:elarch_neuilly)
  end
  
  test "it should correctly serialize address" do
    address_serializer = Vulcain::AddressSerializer.new(@address)
    hash = address_serializer.as_json

    assert_equal @address.first_name, hash[:address][:first_name]
    assert_equal @address.last_name, hash[:address][:last_name]
    assert_equal "0646403619", hash[:address][:mobile_phone]
    assert_equal @address.address1, hash[:address][:address_1]
    assert_equal @address.address2, hash[:address][:address_2]
    assert_equal @address.zip, hash[:address][:zip]
    assert_equal @address.city, hash[:address][:city]
    assert_equal @address.country.iso, hash[:address][:country]
    assert_equal @address.access_info, hash[:address][:additional_address]
  end

  test "it should keep only numbers for zip" do
    @address.zip = "LV-1550"
    address_serializer = Vulcain::AddressSerializer.new(@address)
    hash = address_serializer.as_json

    assert_equal "1550", hash[:address][:zip]
  end
end