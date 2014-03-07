class FlinkerFollow < ActiveRecord::Base
  act_as_flink_activity :follow
  attr_accessible :flinker_id, :follow_id, :skip_notification
  attr_accessor :skip_notification
  
  belongs_to :flinker, include: :country
  belongs_to :following, foreign_key: :follow_id, class_name:'Flinker', include: :country
  
  validates :flinker_id, :presence => true
  validates :follow_id, :presence => true, :uniqueness => { :scope => :flinker_id }
  
  def self.mutual_following flinker, flinkers
    flinkers.each do |flinkr|
      create(follow_id:flinkr.id, flinker_id:flinker.id, skip_notification:true)
      create(follow_id:flinker.id, flinker_id:flinkr.id, skip_notification:true)
    end
  end
  
end
