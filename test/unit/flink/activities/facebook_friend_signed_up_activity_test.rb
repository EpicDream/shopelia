require 'test_helper'

class FacebookFriendSignedUpActivityTest < ActiveSupport::TestCase
  
  setup do
  end
  
  test "create facebook friend signed up activity for friends when a fb friend become flinker" do
    flinker = flinkers(:boop)
    auth = nil
    
    [:fanny, :nana].each do |f|
      SignupNotificationWorker.expects(:perform_async).with(flinkers(f).id, flinker.id)
    end
    
    assert_difference("FacebookFriendSignedUpActivity.count", 2) do
      auth = FacebookAuthentication.create!(provider:"facebook", uid:"9090909", flinker_id:flinker.id)
    end
    
    activities = FacebookFriendSignedUpActivity.all
    
    assert_equal [flinker], activities.map(&:flinker).uniq
    assert_equal [auth], activities.map(&:resource).uniq
    assert_equal [flinkers(:fanny), flinkers(:nana)].to_set, activities.map(&:target).to_set
  end
  
end