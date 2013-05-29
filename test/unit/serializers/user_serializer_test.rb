# -*- encoding : utf-8 -*-
require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  fixtures :users, :addresses, :payment_cards
  
  setup do
    @user = users(:elarch)
  end
  
  test "it should correctly serialize user" do
    user_serializer = UserSerializer.new(@user)
    hash = user_serializer.as_json
      
    assert_equal @user.id, hash[:user][:id]
    assert_equal @user.first_name, hash[:user][:first_name]
    assert_equal @user.last_name, hash[:user][:last_name]
    assert_equal @user.email, hash[:user][:email]
    assert_equal 1, hash[:user][:has_pincode]
    assert_equal 1, hash[:user][:has_password]
    assert hash[:user][:pincode].nil?
    assert hash[:user][:addresses].count > 0
    assert hash[:user][:payment_cards].count > 0
  end

end

