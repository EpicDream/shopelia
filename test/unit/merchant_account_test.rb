require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase
  fixtures :users, :merchants, :merchant_accounts, :addresses
  
  setup do
    @user = users(:elarch)
    @merchant = merchants(:rueducommerce)
    @account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id)
  end

  test "it should create a merchant account" do
    assert @account.persisted?
    assert @account.is_default?, "Account should be default"
    assert_equal 8, @account.password.size
    assert_equal "elarch.gmail.com@shopelia.fr", @account.login
    assert_equal addresses(:elarch_neuilly).id, @account.address_id
  end

  test "it should be impossible to create two accounts with same login for same merchant" do
    account = MerchantAccount.new(
      :user_id => users(:manu).id,
      :merchant_id => @merchant.id,
      :login => @account.login)
    assert !account.save
  end
  
  test "a new account specified as default should set previous one as non default" do
    account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id, is_default:true)
    assert account.is_default?
    assert !@account.reload.is_default?
  end
  
  test "a second account shouldn't be default" do
    account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id)
    assert !account.is_default?
  end
  
  test "when a default account is destroyed, last one standing should be default" do
    account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id)
    @account.destroy
    assert account.reload.is_default?
  end
  
  test "it should find or create a new merchant account" do
    assert_equal @account.id, MerchantAccount.find_or_create(@user, @merchant).id
    assert MerchantAccount.find_or_create(users(:manu), @merchant).present?
  end
  
end
