class Event < ActiveRecord::Base
  belongs_to :product
  belongs_to :developer
  belongs_to :device
  belongs_to :user
  has_many :merchants, :through => :product
  
  VIEW = 0
  CLICK = 1
  
  validates :product, :presence => true
  validates :developer, :presence => true
  validates :device, :presence => true
  validates :action, :presence => true, :inclusion => { :in => [ VIEW, CLICK ] }

  before_validation :find_or_create_product
  before_validation :set_monetizable

  attr_accessible :url, :product_id, :developer_id, :device_id, :action, :tracker, :ip_address
  attr_accessor :url

  scope :for_developer, lambda { |developer| where(developer_id:developer.id) }
  scope :for_tracker, lambda { |tracker| where(tracker:tracker) }
  scope :views, where(action:VIEW)
  scope :clicks, where(action:CLICK)
  
  def self.from_urls data
    data[:urls].each do |url|
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
    mlink = Linker.monetize(self.product.url)
    self.monetizable = !mlink.eql?(self.product.url)
    true
  end
end
