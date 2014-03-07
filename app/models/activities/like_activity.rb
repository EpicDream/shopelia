class LikeActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerLike'
  
  def self.create! flinker_like
    return if flinker_like.product?
    flinker = flinker_like.flinker
    flinker.friends.each do |friend|
      super(flinker_id:flinker.id, target_id:friend.id, resource_id:flinker_like.id)
    end
  end
  
  def self.destroy_related_to! flinker_like
    return if flinker_like.product?
    LikeActivity.where(resource_id:flinker_like.id).destroy_all
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
