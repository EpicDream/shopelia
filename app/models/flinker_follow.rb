class FlinkerFollow < ActiveRecord::Base
  belongs_to :flinker

  validates :flinker_id, :presence => true
  validates :follow_id, :presence => true, :uniqueness => { :scope => :flinker_id }

  attr_accessible :flinker_id, :follow_id
end