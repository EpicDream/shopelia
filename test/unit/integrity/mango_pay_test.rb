require 'test_helper'

class Integrity::MangoPayTest < ActiveSupport::TestCase

  setup do
    user = users(:elarch)
    user.update_attribute :mangopay_id, 5

    b = BillingTransaction.create!(meta_order_id:meta_orders(:elarch_billing).id,amount:1000)
    b.created_at = "2013-07-11 10:00"
    b.mangopay_contribution_id = 20
    b.mangopay_destination_wallet_id = 10
    b.success = true
    b.save!
  end

  test "it should report bad line" do
    report =<<__END
garbage
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_equal "Invalid line format -- garbage", result[0]
  end
  
  test "it should match all lines" do
    report =<<__END
textbox1
Report shopelia

TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId
contribution,20,7/11/2013 9:48:48 AM,5,Larcheveque,Eric,1000,0,,,,10
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_equal 1, result.size
  end

  test "it should fail bad transaction id" do
    report =<<__END
textbox1
Report shopelia

TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId
contribution,21,7/11/2013 9:48:48 AM,5,Larcheveque,Eric,1000,0,,,,10
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_equal 2, result.count
    assert_match /Impossible to find order with transaction_id/, result[0]
    assert_match /Inconsistent contribution_ids/, result[1]
    assert_match /21/, result[1]
  end

  test "it should fail bad user id" do
    report =<<__END
textbox1
Report shopelia

TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId
contribution,20,7/11/2013 9:48:48 AM,6,Larcheveque,Eric,1000,0,,,,10
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_match /User ID doesn't match/, result[0]
  end  

  test "it should fail bad wallet id" do
    report =<<__END
textbox1
Report shopelia

TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId
contribution,20,7/11/2013 9:48:48 AM,5,Larcheveque,Eric,1000,0,,,,11
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_match /Wallet ID doesn't match/, result[0]
  end  
  
  test "it should fail bad amount" do
    report =<<__END
textbox1
Report shopelia

TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId
contribution,20,7/11/2013 9:48:48 AM,5,Larcheveque,Eric,500,0,,,,10
__END
    result = Integrity::MangoPay.verify_report(report)
    assert_match /Amounts not consistent/, result[0]
  end   
   
end
