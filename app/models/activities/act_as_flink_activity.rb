class ActiveRecord::Base
  
  def self.act_as_flink_activity activity
    self.after_create(:"flink_create_#{activity}_activity")
  end
  
  def flink_create_follow_activity
    FollowActivity.create!(self)
  end
  
  def flink_create_comment_activity
    CommentActivity.create!(self)
  end
  
  def flink_create_mention_activity
    MentionActivity.create!(self)
  end
  
  def flink_create_like_activity
    LikeActivity.create!(self)
  end
  
  def flink_create_facebook_friend_signed_up_activity
    FacebookFriendSignedUpActivity.create!(self)
  end
  
  
end