require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase
  fixtures :users, :merchants
  
  setup do
    @user = users(:elarch)
    @merchant = merchants(:rueducommerce)
    @account = MerchantAccount.create(
      :user_id => @user.id,
      :merchant_id => @merchant.id,
      :login => "eric@gmail.com",
      :password => "1234")
  end

  test "it should create a merchant account" do
    assert @account.persisted?
    assert @account.is_default?, "Account should be default"
  end

  test "it should be impossible to create two accounts with same login for same merchant" do
    account = MerchantAccount.new(
      :user_id => users(:manu).id,
      :merchant_id => @merchant.id,
      :login => "eric@gmail.com",
      :password => "1234")
    assert !account.save
  end
  
  test "a new account specified as default should set previous one as non default" do
    account = MerchantAccount.create(
      :user_id => @user.id,
      :merchant_id => @merchant.id,
      :is_default => true,
      :login => "elarch2@gmail.com",
      :password => "1234")
    assert account.is_default?
    assert !@account.reload.is_default?
  end
  
  test "a second account shouldn't be default" do
    account = MerchantAccount.create(
      :user_id => @user.id,
      :merchant_id => @merchant.id,
      :login => "elarch2@gmail.com",
      :password => "1234")
    assert !account.is_default?
  end
  
  test "when a default account is destroyed, last one standing should be default" do
    account = MerchantAccount.create(
      :user_id => @user.id,
      :merchant_id => @merchant.id,
      :login => "elarch2@gmail.com",
      :password => "1234")
    @account.destroy
    assert account.reload.is_default?
  end
  
end
