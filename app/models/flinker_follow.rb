class FlinkerFollow < ActiveRecord::Base
  MIN_DATE = Date.parse("2014-01-01")
  
  act_as_flink_activity :follow
  default_scope where(on:true)
  
  attr_accessible :flinker_id, :follow_id, :skip_notification, :on
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
  
  def self.toggle_or_create flinker_id, follow_id
    follow = self.unscoped { where(flinker_id: flinker_id, follow_id: follow_id).first }
    if follow
      follow.update_attributes(on: !follow.on)
    else
      create(flinker_id:flinker_id, follow_id: follow_id)
    end
  end
  
  
end
