class PrivateMessage < ActiveRecord::Base
  act_as_flink_activity :private_message
  
  attr_accessible :content, :flinker_id, :target_id, :look_id
  
  belongs_to :look
  belongs_to :flinker
  belongs_to :target, foreign_key: :target_id, class_name:'Flinker'
  
  validates :flinker, presence:true
  validates :target, presence:true
  
end