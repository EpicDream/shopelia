require 'test_helper'
require 'flinker_merge'

class FlinkerMergeTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:fanny)
    @target = flinkers(:betty)
    follow(flinkers(:boop), @flinker)
    follow(flinkers(:fanny), flinkers(:lilou))
    @flinker.authentication_token = "ZZZZZZZZ"
    @flinker.save!
  end
  
  test "merge" do
    assert_associations_moved do
      merger = FlinkerMerge.new(@flinker, @target)
      merger.merge
    
      assert_equal "nicolasbigot@icloud.com", @target.email
      assert_equal @flinker.encrypted_password, @target.encrypted_password
    end
  end
  
  test "merge must remove self follow if old flinker was following target" do
    follow(flinkers(:betty), flinkers(:fanny))
    
    merger = FlinkerMerge.new(@flinker, @target)
    merger.merge
    
    assert !@target.followers.include?(@target), 'Must not follow herself after merge'
  end
  
  def assert_associations_moved
    before_counts = associations_counts()
    yield
    associations_counts.each_with_index do |(f, t), i|
      assert_equal 0, f
      assert_equal before_counts[i][0] + before_counts[i][1], t
    end
  end
  
  def associations_counts
    FlinkerMerge::KLASSES.map do |klass|
      [klass.where(flinker_id:@flinker.id).count, klass.where(flinker_id:@target.id).count]
    end +
    [FlinkerFollow].map do |klass|
      [klass.where(follow_id:@flinker.id).count, klass.where(follow_id:@target.id).count]
    end +
    [Activity].map do |klass|
      [klass.where(target_id:@flinker.id).count, klass.where(target_id:@target.id).count]
    end +
    [FacebookFriend].map do |klass|
      [klass.where(friend_flinker_id:@flinker.id).count, klass.where(friend_flinker_id:@target.id).count]
    end
  end
  
end