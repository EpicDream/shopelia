# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::UserSerializerTest < ActiveSupport::TestCase
  fixtures :users, :addresses
  
  setup do
    @user = users(:elarch)
  end
  
  test "it should correctly serialize user" do
    user_serializer = Vulcain::UserSerializer.new(@user, scope:{address_id:@user.addresses.first.id})
    hash = user_serializer.as_json
      
    assert_equal 0, hash[:user][:gender]
    assert_equal 30, hash[:user][:birthdate][:day]
    assert_equal 9, hash[:user][:birthdate][:month]
    assert_equal 1973, hash[:user][:birthdate][:year]
    assert hash[:user][:address].present?
  end

end

