require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase
  fixtures :users, :merchants, :merchant_accounts, :addresses, :orders, :order_items, :products, :product_versions
  
  setup do
    @user = users(:elarch)
    @merchant = merchants(:rueducommerce)
    @address = addresses(:elarch_vignoux)
    @account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id, address_id:@address.id)
  end

  test "it should create a merchant account" do
    assert @account.persisted?
    assert @account.is_default?, "Account should be default"
    assert_equal 8, @account.password.size
    assert_equal "elarch.gmail.com@shopelia.fr", @account.login
    assert_equal addresses(:elarch_vignoux).id, @account.address_id
  end

  test "it shouldn't be marked as created by default" do
    assert !@account.merchant_created?
  end
  
  test "it should confirm creation" do
    @account.confirm_creation!
    assert @account.merchant_created?
  end
  
  test "it should create second merchant account" do
    account2 = MerchantAccount.new(user_id:@user.id, merchant_id:@merchant.id)
    assert account2.save
    assert_equal "elarch.gmail.com.2@shopelia.fr", account2.login
  end

  test "it should be impossible to create two accounts with same login for same merchant" do
    account = MerchantAccount.new(
      :user_id => users(:manu).id,
      :merchant_id => @merchant.id,
      :login => @account.login)
    assert !account.save
  end
  
  test "a new account should set previous one as non default" do
    account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id, address_id:@address.id)
    assert account.is_default?
    assert !@account.reload.is_default?
  end
  
  test "when a default account is destroyed, last one standing should be default" do
    account = MerchantAccount.create!(user_id:@user.id, merchant_id:@merchant.id)
    @account.destroy
    merchant_accounts(:elarch_neuilly_rueducommerce).destroy
    assert account.reload.is_default?
  end
  
  test "it should find or create a new merchant account for order" do
    assert MerchantAccount.find_or_create_for_order(orders(:elarch_rueducommerce)).present?
  end

  test "it should fail all non completed orders attached to a destroyed merchant account" do
    order = orders(:elarch_rueducommerce)
    assert_equal :initialized, order.state
    order.merchant_account.destroy
    
    assert_equal :failed, order.reload.state
    assert_equal "user", order.error_code
    assert_equal "merchant_account_destroyed", order.message
  end

  test "it shouldn't fail a completed orders attached to a destroyed merchant account" do
    order = orders(:elarch_rueducommerce)
    order.update_attribute :state_name, "completed"
    order.merchant_account.destroy
    
    assert_equal :completed, order.reload.state
  end  
  
end
