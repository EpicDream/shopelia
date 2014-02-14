class LikeActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerLike'
  
  def self.create! flinker_like
    return if flinker_like.resource_type == FlinkerLike::PRODUCT
    super(flinker_id:flinker_like.flinker_id, target_id:flinker_like.look.flinker.id, resource_id:flinker_like.id)
  end
end
