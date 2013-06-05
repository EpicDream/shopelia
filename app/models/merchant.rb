class Merchant < ActiveRecord::Base
  has_many :products, :dependent => :destroy
  has_many :orders

  validates :name, :presence => true, :uniqueness => true
  validates :vendor, :presence => true, :uniqueness => true
  validates :url, :presence => true, :uniqueness => true
  
  scope :accepting_orders, :conditions => ['accepting_orders = ?', true]
  
  attr_accessible :id, :name, :vendor, :url, :tc_url, :logo
  
  before_destroy :check_presence_of_orders
  
  def self.from_url url
    return nil if url.blank?
    begin
      merchant = Merchant.where("url like ?", "http://#{URI.parse(url.gsub(/[^0-9a-z\-\.\/\:]/, "")).host}%").first
      return merchant unless merchant.nil?
    rescue
    end
    Merchant.all.each do |merchant|
      host = URI.parse(merchant.url).host.gsub("www.", "")
      return merchant if url.include? host
    end
    nil
  end
  
  private
  
  def check_presence_of_orders
    self.orders.count == 0
  end
end
