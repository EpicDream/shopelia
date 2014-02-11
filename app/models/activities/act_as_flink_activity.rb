class ActiveRecord::Base
  def self.act_as_flink_activity activity
    self.after_create(:"__flink_create_#{activity}_activity")
  end
  
  def __flink_create_follow_activity
    FollowActivity.create!(flinker_id:self.flinker_id, resource_id:self.follow_id)
  end
end