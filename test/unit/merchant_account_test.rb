require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase
  
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
    assert_equal "elarch.gmail.com@shopelia.com", @account.login
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
    assert_equal "elarch.gmail.com.2@shopelia.com", account2.login
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
    assert_difference "MerchantAccount.count", 0 do
      Order.create!(
        :user_id => users(:elarch).id,
        :developer_id => developers(:prixing).id,
        :payment_card_id => payment_cards(:elarch_hsbc).id,
        :products => [ { :price => 90, :url => "http://www.amazon.fr/productA" } ],
        :address_id => addresses(:elarch_vignoux).id,
        :expected_cashfront_value => 2.7,
        :expected_price_total => 90)
    end
    assert_difference "MerchantAccount.count" do
      Order.create!(
        :user_id => users(:elarch).id,
        :developer_id => developers(:prixing).id,
        :payment_card_id => payment_cards(:elarch_hsbc).id,
        :products => [ { :price => 90, :url => "http://www.cdiscount.com/informatique/tablettes-tactiles-ebooks/tablette-7-4go/f-10798010208-ta28805.html" } ],
        :address_id => addresses(:elarch_vignoux).id,
        :expected_price_total => 90)
    end
    assert_difference "MerchantAccount.count" do
      Order.create!(
        :user_id => users(:elarch).id,
        :developer_id => developers(:prixing).id,
        :payment_card_id => payment_cards(:elarch_hsbc).id,
        :products => [ { :price => 90, :url => "http://www.cdiscount.com/informatique/tablettes-tactiles-ebooks/tablette-pc-wifi-arnova-8-g2-8-go/f-10798010201-arn0690590518353.html" } ],
        :address_id => addresses(:elarch_neuilly).id,
        :expected_price_total => 90)
    end
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