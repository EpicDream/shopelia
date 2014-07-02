class LikeActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerLike'
  
  def self.create! flinker_like
    return if flinker_like.product?
    flinker = flinker_like.flinker
    LikeActivityWorker.perform_async(flinker_like.id)
  end
  
  def self.destroy_related_to! flinker_like
    return if flinker_like.product?
    LikeActivity.where(resource_id:flinker_like.id).destroy_all
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
