class Merchant < ActiveRecord::Base
  has_many :products, :dependent => :destroy
  has_many :orders

  validates :name, :presence => true, :uniqueness => true
  validates :domain, :presence => true, :uniqueness => true
  validates :vendor, :uniqueness => true, :allow_nil => true
  validates :url, :uniqueness => true, :allow_nil => true
  
  scope :accepting_orders, :conditions => ['accepting_orders = ?', true]
  
  attr_accessible :id, :name, :vendor, :url, :tc_url, :logo, :domain, :viking_data
  
  before_validation :populate_name
  before_destroy :check_presence_of_orders
  
  def self.from_url url, create=true
    domain = Utils.extract_domain(Linker.clean(url))
    if create
      Merchant.find_or_create_by_domain(domain)
    else
      Merchant.find_by_domain(domain)
    end
    rescue 
      nil
  end
  
  private
  
  def populate_name
    self.name = self.domain if self.name.blank?
  end
  
  def check_presence_of_orders
    self.orders.count == 0
  end
end
