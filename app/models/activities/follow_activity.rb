class FollowActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerFollow'
  
  def self.create! follow
    super(flinker_id:follow.flinker_id, target_id:follow.follow_id, resource_id:follow.id)
    FollowNotificationWorker.perform_in(10.seconds, follow.follow_id, follow.flinker_id) unless follow.skip_notification
  end
  
end
