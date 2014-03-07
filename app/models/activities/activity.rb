class Activity < ActiveRecord::Base
  attr_accessible :flinker_id, :resource_id, :target_id
  
  belongs_to :flinker
  belongs_to :target, foreign_key: :target_id, class_name:'Flinker'
  
  scope :for_flinker, ->(flinker, since=1.week) { 
    where(target_id:flinker.id).where('created_at >= ?', Time.now - since) 
  }
  
end