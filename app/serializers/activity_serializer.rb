class ActivitySerializer < ActiveModel::Serializer
  attributes :flinker_id, :comment_id, :look_uuid, :type, :created_at
  
  def comment_id
    object.comment_id if object.respond_to?(:comment_id)
  end
  
  def look_uuid
    object.look_uuid if object.respond_to?(:look_uuid)
  end
  
  def created_at
    object.created_at.to_i
  end
  
end