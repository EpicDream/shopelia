require 'test_helper'

class SignupWelcomeWorkerTest < ActiveSupport::TestCase
  
  test "send welcome email and autofollowed from flinkHQ" do
    flinker = flinkers(:fanny)
    flinkhq = flinkers(:flinkhq)
    flinkhq.update_attributes(username:'flinkhq')
    
    Emailer.expects(:after_signup).with(flinker)
    
    SignupWelcomeWorker.new.perform(flinker.id)
    
    assert flinker.followers.include?(flinkhq)
  end
end