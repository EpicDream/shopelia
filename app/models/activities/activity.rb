class Activity < ActiveRecord::Base
  MIN_BUILD_FOR_PRIVATE_MESSAGES = 30
  
  attr_accessible :flinker_id, :resource_id, :target_id
  
  belongs_to :flinker
  belongs_to :target, foreign_key: :target_id, class_name:'Flinker'
  
  scope :for_flinker, ->(flinker, since=1.week) { 
    query = where(target_id:flinker.id).where('created_at >= ?', Time.now - since) 
    if flinker.device && flinker.device.build < MIN_BUILD_FOR_PRIVATE_MESSAGES
      query.where("type <> 'PrivateMessageActivity'")
    else
      query
    end
  }
  
end