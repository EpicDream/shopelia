class FlinkerFollow < ActiveRecord::Base
  act_as_flink_activity :follow
  default_scope where(on:true)
  
  attr_accessible :flinker_id, :follow_id, :skip_notification, :on, :updated_at
  attr_accessor :skip_notification
  
  belongs_to :flinker, include: :country
  belongs_to :following, foreign_key: :follow_id, class_name:'Flinker', include: :country
  
  validates :flinker_id, :presence => true
  validates :follow_id, :presence => true, :uniqueness => { :scope => :flinker_id }
  
  scope :of_flinker_following, ->(flinker_id, follow_id) {
    where(flinker_id: flinker_id, follow_id: follow_id).limit(1)
  }
  
  def self.mutual_following flinker, flinkers
    flinkers.each do |flinkr|
      create(follow_id:flinkr.id, flinker_id:flinker.id, skip_notification:true)
      create(follow_id:flinker.id, flinker_id:flinkr.id, skip_notification:true)
    end
  end
  
  def self.follow flinker_id, follow_id 
    follow = self.unscoped { of_flinker_following(flinker_id, follow_id).first }
    if follow
      follow.update_attributes(on: true)
    else
      create(flinker_id:flinker_id, follow_id: follow_id)
    end
  end
  
  def self.unfollow flinker_id, follow_id
    follow = self.unscoped { of_flinker_following(flinker_id, follow_id).first }
    follow.update_attributes(on: false) if follow
  end
  
  
end
