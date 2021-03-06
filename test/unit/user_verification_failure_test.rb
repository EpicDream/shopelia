require 'test_helper'

class UserVerificationFailureTest < ActiveSupport::TestCase
  
  setup do
    @user = users(:elarch)
  end
  
  test "it should create user verification failure" do
    uvf = UserVerificationFailure.new(user_id:@user.id)
    assert uvf.save, uvf.errors.full_messages.join(",")
  end

  test "it shouldn't have delay after one failure" do
    UserVerificationFailure.create(user_id:@user.id)
    assert_equal 0, UserVerificationFailure.delay(@user)
  end
  
  test "user should be blocked for one minute after three consecutive failures, and more after" do
    fail_3_times

    assert [59,60].include?(UserVerificationFailure.delay(@user))

    UserVerificationFailure.create(user_id:@user.id)
    assert [119,120].include?(UserVerificationFailure.delay(@user))
    
    UserVerificationFailure.create(user_id:@user.id)
    assert [239,240].include?(UserVerificationFailure.delay(@user))
  end
  
  test "delay should decrement with time since last failure" do
    fail_3_times
    
    uvf = UserVerificationFailure.order("created_at desc").pop
    uvf.update_column "created_at", Time.at(uvf.created_at.to_i - 10)
    assert [49,50].include?(UserVerificationFailure.delay(@user))
  end
  
  private
  
  def fail_3_times
    UserVerificationFailure.create(user_id:@user.id)
    UserVerificationFailure.create(user_id:@user.id)
    UserVerificationFailure.create(user_id:@user.id)
  end
  
end
