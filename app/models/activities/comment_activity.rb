class CommentActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  def self.create! comment
    CommentActivityWorker.perform_in(1.minute, comment.id)
  end
  
  def comment_id
    resource.id
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
