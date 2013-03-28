# -*- encoding : utf-8 -*-
require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  fixtures :users, :addresses, :phones
  
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
    assert_equal @user.authentication_token, hash[:user][:auth_token]
    assert hash[:user][:addresses].count > 0
    assert hash[:user][:phones].count > 0
  end

end

