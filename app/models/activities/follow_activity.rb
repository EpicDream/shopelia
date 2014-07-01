class FollowActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerFollow'
  
  def self.create! follow
    return if !follow.following || follow.following.publisher?
    unless follow.skip_notification
      super(flinker_id:follow.flinker_id, target_id:follow.follow_id, resource_id:follow.id)
      FollowNotificationWorker.perform_in(10.seconds, follow.follow_id, follow.flinker_id)
    end
  end
  
  def self.destroy_related_to! follow
    FollowActivity.where(resource_id:follow.id).destroy_all
  end
  
end
