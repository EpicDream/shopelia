class MentionActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'Comment'
  
  def self.create! comment
    flinkers_mentionned_in(comment.body).each { |flinker|  
      super(flinker_id:comment.flinker_id, target_id:flinker.id, resource_id:comment.id)
    }
  end
  
  def self.flinkers_mentionned_in text
    usernames = text.scan(/@([\w\d]+)\s/)
    Flinker.where(username:usernames)
  end
  
end
