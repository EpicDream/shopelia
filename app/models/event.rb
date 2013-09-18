class Event < ActiveRecord::Base
  belongs_to :product
  belongs_to :developer
  belongs_to :device
  has_one :merchant, :through => :product
  
  VIEW = 0
  CLICK = 1
  REQUEST = 2
  
  validates :product, :presence => true
  validates :developer, :presence => true
  validates :device, :presence => true
  validates :action, :presence => true, :inclusion => { :in => [ VIEW, CLICK, REQUEST ] }

  before_validation :find_or_create_product
  before_validation :set_monetizable
  after_create :reset_viking_sent_at

  attr_accessible :url, :product_id, :developer_id, :device_id, :action, :tracker, :ip_address
  attr_accessor :url

  scope :for_developer, lambda { |developer| where(developer_id:developer.id) }
  scope :for_tracker, lambda { |tracker| where(tracker:tracker) }
  scope :views, where(action:VIEW)
  scope :clicks, where(action:CLICK)
  scope :requests, where(action:REQUEST)
  scope :buttons, where(action:[VIEW, CLICK])
  
  def self.from_urls data
    data[:urls].each do |url|
      next if url.blank?
      Event.create!(
        :url => url,
        :action => data[:action],
        :developer_id => data[:developer_id],
        :device_id => data[:device_id],
        :tracker => data[:tracker],
        :ip_address => data[:ip_address])
    end
  end        
  
  private
  
  def find_or_create_product
    self.product = Product.fetch(self.url) unless self.url.blank?
  end
  
  def set_monetizable
    if self.product.present?
      mlink = Linker.monetize(self.product.url)
      self.monetizable = !mlink.eql?(self.product.url)
      true
    end
  end

  def reset_viking_sent_at
    self.product.update_column "viking_sent_at", nil if self.product.versions_expired?
  end
end