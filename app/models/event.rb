class Event < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  belongs_to :developer
  
  VIEW = 0
  CLICK = 1
  
  validates :product, :presence => true
  validates :developer, :presence => true
  validates :action, :presence => true, :inclusion => { :in => [ VIEW, CLICK ] }

  before_validation :find_or_create_product

  attr_accessor :url
  
  def self.from_urls data
    data[:urls].each do |url|
      Event.create!(
        :url => url,
        :action => data[:action],
        :developer_id => data[:developer_id],
        :visitor => data[:visitor],
        :tracker => data[:tracker],
        :user_agent => data[:user_agent],
        :ip_address => data[:ip_address])
    end
  end        
  
  private
  
  def find_or_create_product
    self.product = Product.fetch(self.url) unless self.url.blank?
  end
  
end
