class Device < ActiveRecord::Base
  belongs_to :user
  has_many :events
  has_many :messages
  
  validates :uuid, :presence => true, :uniqueness => true
  validates :user_agent, :presence => true
  
  before_validation :generate_uuid

  attr_accessible :push_token, :os, :os_version, :version, :build
  attr_accessible :referrer, :phone, :user_agent, :email, :uuid
  
  def self.fetch uuid, ua
    Device.find_by_uuid(uuid) || Device.create(uuid:uuid,user_agent:ua)
  end
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
end
