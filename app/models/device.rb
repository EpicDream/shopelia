class Device < ActiveRecord::Base
  belongs_to :user
  belongs_to :flinker
  has_many :events
  has_many :messages
  has_many :cashfront_rules
  has_many :user_sessions
  has_many :traces
  
  validates :uuid, :presence => true, :uniqueness => true
  
  before_validation :generate_uuid
  after_update :notify_georges_lobby

  attr_accessible :push_token, :os, :os_version, :version, :build
  attr_accessible :referrer, :phone, :user_agent, :email, :uuid
  attr_accessible :pending_answer, :is_dev, :is_beta, :rating, :flinker_id
  
  def self.fetch uuid, ua
    Device.find_by_uuid(uuid) || Device.create(uuid:uuid,user_agent:ua)
  end

  def self.from_flink_user_agent ua, flinker
    hash = ua.gsub(/^flink:/, "").split(/\:/).map{|e| e.match(/^(.*)\[(.*)\]$/)[1..2]}.map{|e| { e[0] => e[1] }}.inject(:merge)
    device = Device.find_or_create_by_uuid(hash["uuid"])
    device.os = hash["os"]
    device.os_version = hash["os_version"]
    device.version = hash["version"]
    device.build = hash["build"].to_i
    device.phone = hash["phone"]
    device.is_dev = hash["dev"].to_i == 1
    device.is_beta = hash["dev"].to_i == 2
    device.flinker_id = flinker.id
    device.save
    device
  end

  def self.from_user_agent ua
    hash = ua.gsub(/^shopelia:/, "").split(/\:/).map{|e| e.match(/^(.*)\[(.*)\]$/)[1..2]}.map{|e| { e[0] => e[1] }}.inject(:merge)
    device = Device.find_or_create_by_uuid(hash["uuid"])
    device.os = hash["os"]
    device.os_version = hash["os_version"]
    device.version = hash["version"]
    device.build = hash["build"].to_i
    device.phone = hash["phone"]
    device.is_dev = hash["dev"].to_i == 1
    device.save
    device
  end
  
  def android?
    self.os == 'Android'
  end

  def ios?
    self.os == 'iOS'
  end
  
  def real_user?
    !(is_dev && is_beta)
  end

  def authorize_push_channel
    Nest.new("device")[self.id][:created_at].set(Time.now.to_i)
  end

  def push_channel_authorized?
    ts = Nest.new("device")[self.id][:created_at].get.to_i
    ts > Time.now.to_i - 2.hours.to_i
  end
  
  def env
    return :development if is_dev?
    return :beta if is_beta?
    :production
  end

  private
  
  def notify_georges_lobby    
    Pusher.trigger("georges-lobby", "refresh", {}) if self.pending_answer_changed?
  end

  def generate_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
end
