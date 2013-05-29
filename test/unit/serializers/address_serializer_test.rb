# -*- encoding : utf-8 -*-
require 'test_helper'

class AddressSerializerTest < ActiveSupport::TestCase
  fixtures :addresses, :users, :states, :countries
  
  setup do
    @address = addresses(:elarch_neuilly)
  end
  
  test "it should correctly serialize address" do
    address_serializer = AddressSerializer.new(@address)
    hash = address_serializer.as_json
    
    assert_equal @address.id, hash[:address][:id]
    assert_equal @address.code_name, hash[:address][:code_name]
    assert_equal @address.address1, hash[:address][:address1]
    assert_equal @address.address2, hash[:address][:address2]
    assert_equal @address.zip, hash[:address][:zip]
    assert_equal @address.city, hash[:address][:city]
    assert_equal @address.country.iso, hash[:address][:country]
    assert_equal @address.state.name, hash[:address][:state]
    assert_equal @address.access_info, hash[:address][:access_info]
    assert_equal @address.phone, hash[:address][:phone]
    assert_equal 1, hash[:address][:is_default]
  end

end

