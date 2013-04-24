require 'test_helper'

class EmailRedirectionTest < ActiveSupport::TestCase
  fixtures :users, :merchants
  
  test "it should create an email redirection" do
    redir = EmailRedirection.new(:user_name => "elarch.gmail.com", :destination => "elarch@gmail.com")
    assert redir.save
  end 
  
  test "user name should be unique, destination can be multiple" do
    EmailRedirection.create(:user_name => "elarch.gmail.com", :destination => "elarch@gmail.com")
    redir = EmailRedirection.new(:user_name => "elarch.gmail.com.2", :destination => "elarch@gmail.com")
    assert redir.save
    redir = EmailRedirection.new(:user_name => "elarch.gmail.com", :destination => "toto@gmail.com")
    assert !redir.save
  end
  
  test "email redirections should be created and destroyed relative to merchant accounts" do
    account1 = MerchantAccount.create!(user_id:users(:manu).id, merchant_id:merchants(:rueducommerce).id)
    assert_equal 1, EmailRedirection.where(:user_name => "manu.gmail.com", :destination => "manu@gmail.com").count

    account2 = MerchantAccount.create!(user_id:users(:manu).id, merchant_id:merchants(:amazon).id)
    assert_equal 1, EmailRedirection.where(:user_name => "manu.gmail.com", :destination => "manu@gmail.com").count

    account2.destroy!
    assert_equal 1, EmailRedirection.where(:user_name => "manu.gmail.com", :destination => "manu@gmail.com").count
    
    account1.destroy!
    assert_equal 0, EmailRedirection.where(:user_name => "manu.gmail.com", :destination => "manu@gmail.com").count    
  end
  
end
