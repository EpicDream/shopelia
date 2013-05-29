class Merchant < ActiveRecord::Base
  has_many :products, :dependent => :destroy
  has_many :orders

  validates :name, :presence => true, :uniqueness => true
  validates :vendor, :presence => true, :uniqueness => true
  validates :url, :presence => true, :uniqueness => true
  
  attr_accessible :id, :name, :vendor, :url, :tc_url, :logo
  
  before_destroy :check_presence_of_orders
  
  def self.from_url url
    Merchant.where("url like ?", "http://#{URI.parse(url).host}%").first
    rescue
      nil
  end
  
  private
  
  def check_presence_of_orders
    self.orders.count == 0
  end
end
