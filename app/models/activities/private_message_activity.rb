class PrivateMessageActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'PrivateMessage'
  
  def self.create! message
    super(flinker_id:message.flinker_id, target_id:message.target_id, resource_id:message.id)
    if message.answer?
      PrivateMessageAnswerActivity.create!(message)
    end
  end
  
  def look_uuid
    resource.look.uuid
  end

end
