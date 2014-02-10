class Mention < ActiveRecord::Base
  attr_accessible :flinker_id, :comment_id, :flinker_mentionned_id
  
  belongs_to :flinker
  belongs_to :mentionned, foreign_key: :flinker_mentionned_id, class_name:'Flinker'
end