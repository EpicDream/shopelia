class Device < ActiveRecord::Base
  belongs_to :user
  has_many :events
  has_many :messages
  has_many :cashfront_rules
  
  validates :uuid, :presence => true, :uniqueness => true
  
  before_validation :generate_uuid

  attr_accessible :push_token, :os, :os_version, :version, :build
  attr_accessible :referrer, :phone, :user_agent, :email, :uuid
  attr_accessible :pending_answer
  
  def self.fetch uuid, ua
    Device.find_by_uuid(uuid) || Device.create(uuid:uuid,user_agent:ua)
  end

  def self.from_user_agent ua
    hash = ua.gsub(/^shopelia:/, "").split(/\:/).map{|e| e.match(/^(.*)\[(.*)\]$/)[1..2]}.map{|e| { e[0] => e[1] }}.inject(:merge)
    device = Device.find_or_create_by_uuid(hash["uuid"])
    device.os = hash["os"]
    device.os_version = hash["os_version"]
    device.version = hash["version"]
    device.build = hash["build"].to_i
    device.phone = hash["phone"]
    device.save
    device
  end
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
end
