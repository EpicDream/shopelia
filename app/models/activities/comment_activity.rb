class CommentActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  def self.create! comment
    friends = comment.flinker.friends
    friends.each do |friend|
      next if CommentTimelineActivity.for_comment_and_target(comment, friend).first
      super(flinker_id:comment.flinker_id, target_id:friend.id, resource_id:comment.id)
    end
  end
  
  def comment_id
    resource.id
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
