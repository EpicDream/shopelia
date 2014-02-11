class FollowActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerFollow'
  
  def self.create! follow
    super(flinker_id:follow.flinker_id, target_id:follow.follow_id, resource_id:follow.id)
  end
end
