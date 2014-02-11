class FlinkerFollow < ActiveRecord::Base
  act_as_flink_activity :follow
  attr_accessible :flinker_id, :follow_id
  
  belongs_to :flinker
  belongs_to :following, foreign_key: :follow_id, class_name:'Flinker'
  
  validates :flinker_id, :presence => true
  validates :follow_id, :presence => true, :uniqueness => { :scope => :flinker_id }

  after_save :update_flinker_follows_count
  
  def self.mutual_following flinker, flinkers
    flinkers.each do |flinkr|
      create(follow_id:flinkr.id, flinker_id:flinker.id)
      create(follow_id:flinker.id, flinker_id:flinkr.id)
    end
  end
  
  private

  def update_flinker_follows_count
    Flinker.find(self.follow_id).update_attribute :follows_count, FlinkerFollow.where(follow_id:self.follow_id).count
  end
end
