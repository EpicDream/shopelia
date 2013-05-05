# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::UserSerializerTest < ActiveSupport::TestCase
  fixtures :users, :addresses, :phones
  
  setup do
    @user = users(:elarch)
  end
  
  test "it should correctly serialize user" do
    user_serializer = Vulcain::UserSerializer.new(@user, scope:{address_id:@user.addresses.first.id})
    hash = user_serializer.as_json
      
    assert_equal @user.first_name, hash[:user][:first_name]
    assert_equal @user.last_name, hash[:user][:last_name]
    assert_equal "0646403619", hash[:user][:mobile_phone]
    assert_equal "0940404040", hash[:user][:land_phone]    
    assert_equal 0, hash[:user][:gender]
    assert_equal 30, hash[:user][:birthdate][:day]
    assert_equal 9, hash[:user][:birthdate][:month]
    assert_equal 1973, hash[:user][:birthdate][:year]
    assert hash[:user][:address].present?
  end

end

