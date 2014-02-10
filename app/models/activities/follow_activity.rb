class FollowActivity < Activity
  belongs_to :followed, foreign_key: :resource_id, class_name:'Flinker'
  
end
