# -*- encoding : utf-8 -*-
require 'test_helper'

class Vulcain::MerchantAccountSerializerTest < ActiveSupport::TestCase
  
  setup do
    @account = merchant_accounts(:manu_rueducommerce)
  end
  
  test "it should correctly serialize merchant account" do
    account_serializer = Vulcain::MerchantAccountSerializer.new(@account)
    hash = account_serializer.as_json
    
    assert_equal @account.login, hash[:merchant_account][:login]
    assert_equal @account.password, hash[:merchant_account][:password]
    assert_equal true, hash[:merchant_account][:new_account]

    @account.merchant_created = true
    account_serializer = Vulcain::MerchantAccountSerializer.new(@account)
    hash = account_serializer.as_json   
    assert hash[:merchant_account][:new_account].nil?
  end

end

