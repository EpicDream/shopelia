# -*- encoding : utf-8 -*-
require 'test_helper'

class PhoneSerializerTest < ActiveSupport::TestCase
  fixtures :phones
  
  setup do
    @phone = phones(:phone_neuilly)
  end
  
  test "it should correctly serialize phone" do
    phone_serializer = PhoneSerializer.new(@phone)
    hash = phone_serializer.as_json
      
    assert_equal @phone.id, hash[:phone][:id]
    assert_equal @phone.number, hash[:phone][:number]
    assert_equal @phone.line_type, hash[:phone][:line_type]
    assert_equal @phone.address_id, hash[:phone][:address_id]
  end

  test "it shouldn't send address_id in address context" do
    phone_serializer = PhoneSerializer.new(@phone, scope: { :address_context => true })
    hash = phone_serializer.as_json
      
    assert hash[:phone][:address_id].nil?
  end

end

