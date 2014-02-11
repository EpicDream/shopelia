class CommentActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  def self.create! comment
    super(flinker_id:comment.flinker_id, target_id:comment.look.flinker_id, resource_id:comment.id)
  end
end
