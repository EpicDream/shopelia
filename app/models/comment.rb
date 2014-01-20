class Comment < ActiveRecord::Base
  belongs_to :look
  belongs_to :flinker
  attr_accessible :body , :flinker_id, :look_id
end
