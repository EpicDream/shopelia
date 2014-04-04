class MentionActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  scope :mentionned, ->(flinker, since=1.week) { where(target_id:flinker.id).where('created_at >= ?', Time.now - since) }
  
  def self.create! comment
    flinkers_mentionned_in(comment.body).each { |flinker|  
      super(flinker_id:comment.flinker_id, target_id:flinker.id, resource_id:comment.id)
      MentionNotificationWorker.perform_async(flinker.id, comment.flinker_id)
    }
  end
  
  def self.flinkers_mentionned_in text
    usernames = text.scan(/@([\w\d\._-]+)/i)
    Flinker.where(username:usernames)
  end
  
  def comment_id
    resource.id
  end
  
  def look_uuid
    resource.look.uuid
  end
  
end
