class Event < ActiveRecord::Base

  BOTS = "#{Rails.root}/lib/config/bots.yml"

  belongs_to :product
  belongs_to :developer
  belongs_to :device
  has_one :merchant, :through => :product
  
  VIEW = 0
  CLICK = 1
  REQUEST = 2
  
  validates :product, :presence => true
  validates :action, :presence => true, :inclusion => { :in => [ VIEW, CLICK, REQUEST ] }

  before_validation :find_or_create_product
  before_validation :set_monetizable
  before_validation :check_merchant_accepting_events
  before_validation :check_presence_of_device
  before_validation :check_presence_of_developer
  after_create :reset_viking_sent_at

  attr_accessible :url, :product_id, :developer_id, :device_id, :action, :tracker, :ip_address
  attr_accessor :url

  scope :for_developer, lambda { |developer| where(developer_id:developer.id) }
  scope :for_tracker, lambda { |tracker| where(tracker:tracker) }
  scope :views, where(action:VIEW)
  scope :clicks, where(action:CLICK)
  scope :requests, where(action:REQUEST)
  scope :buttons, where(action:[VIEW, CLICK])
  
  def self.is_bot? ua
    filter = YAML.load(File.open(BOTS))
    filter.each do |f|
      return true if ua =~ /#{f}/i
    end
    false
  end

  private
  
  def find_or_create_product
    self.product_id = Product.fetch(self.url).id unless self.url.blank? || self.url !~ /^http/
  end
  
  def set_monetizable
    if self.product.present?
      mlink = Linker.monetize(self.product.url)
      self.monetizable = !mlink.eql?(self.product.url)
      true
    end
  end

  def check_merchant_accepting_events
    raise Exceptions::RejectingEventsException if self.merchant.present? && self.merchant.rejecting_events?
  end

  def reset_viking_sent_at
    if self.product.persisted? && self.product.versions_expired?
      self.product.update_column "viking_sent_at", nil
      Viking.touch_request
    end
  end

  def check_presence_of_device
    self.errors.add(:base, 'Missing device') if self.device.nil? && self.action != REQUEST
  end

  def check_presence_of_developer
    self.errors.add(:base, 'Missing developer') if self.developer.nil? && self.action != REQUEST
  end
end