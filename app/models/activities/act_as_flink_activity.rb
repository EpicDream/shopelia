class ActiveRecord::Base
  
  def self.act_as_flink_activity activity
    self.after_create(:"flink_create_#{activity}_activity")
    if [:like, :follow].include?(activity)
      self.after_destroy(:"flink_destroy_#{activity}_activities")
    end
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
  
  def flink_create_comment_timeline_activity
    CommentTimelineActivity.create!(self)
  end
  
  def flink_destroy_like_activities
    LikeActivity.destroy_related_to!(self)
  end
  
  def flink_destroy_follow_activities
    FollowActivity.destroy_related_to!(self)
  end
  
  def flink_create_share_activity
    ShareActivity.create!(self)
  end
  
  def flink_create_private_message_activity
    PrivateMessageActivity.create!(self)
  end
  
end