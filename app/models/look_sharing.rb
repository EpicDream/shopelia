class LookSharing < ActiveRecord::Base
  act_as_flink_activity :share
  attr_accessible :look_id, :flinker_id, :social_network_id
  
  belongs_to :look
  belongs_to :flinker
  belongs_to :social_network
  
  validates :look, :presence => true
  validates :flinker, :presence => true
  validates :social_network, :presence => true
  
  def self.on social_network
    instance = self.new
    instance.social_network = SocialNetwork.with_name(social_network).first
    instance
  end
  
  def for look_id:nil, flinker_id:nil
    self.look_id = look_id
    self.flinker_id = flinker_id
    save
  end
  
end
