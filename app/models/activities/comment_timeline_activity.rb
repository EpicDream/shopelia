class CommentTimelineActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  validates :resource_id, uniqueness: { scope:[:flinker_id, :target_id] }
  
  scope :for_comment_and_target, ->(comment, target) {
    where(flinker_id:comment.flinker_id, target_id:target.id, resource_id:comment.id)
  }
  
  def self.create! comment
    comments = Comment.timeline(comment.look_id).where('flinker_id <> ?', comment.flinker_id).includes(:flinker)
    
    comments.map(&:flinker).uniq.each do |flinker|
      super(flinker_id:comment.flinker_id, target_id:flinker.id, resource_id:comment.id)
    end
  end
  
  def comment_id
    resource.id
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
