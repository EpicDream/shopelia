class Device < ActiveRecord::Base
  attr_accessible :user_agent, :uuid, :email

  belongs_to :user
  has_many :events
  
  validates :uuid, :presence => true, :uniqueness => true
  validates :user_agent, :presence => true
  
  before_validation :generate_uuid
  
  def self.fetch uuid, ua
    Device.find_by_uuid(uuid) || Device.create(uuid:uuid,user_agent:ua)
  end
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
    
end
