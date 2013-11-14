class Merchant < ActiveRecord::Base
  audited

  has_many :products, :dependent => :destroy
  has_many :events, :through => :products
  has_many :orders
  has_many :cashfront_rules

  belongs_to :mapping

  validates :name, :presence => true, :uniqueness => true
  validates :domain, :presence => true, :uniqueness => true
  validates :vendor, :uniqueness => true, :allow_nil => true
  validates :url, :uniqueness => true, :allow_nil => true
  
  scope :accepting_orders, :conditions => ['accepting_orders = ? and vendor is not null', true]
  
  attr_accessible :id, :name, :vendor, :url, :tc_url, :logo, :domain, :mapping_id, :viking_data, :accepting_orders
  attr_accessible :billing_solution, :injection_solution, :cvd_solution, :should_clean_args, :allow_quantities
  attr_accessible :rejecting_events, :multiple_addresses
  
  before_validation :populate_name
  before_validation :nullify_vendor
  before_destroy :check_presence_of_orders
  before_destroy :clean_incidents
  after_update :notify_leftronic_vulcain_test_semaphore
  
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

  def nullify_vendor
    self.vendor = nil if self.vendor.blank?
  end
  
  def check_presence_of_orders
    self.orders.count == 0
  end

  def clean_incidents
    Incident.where(resource_type:'Merchant', resource_id:self.id).destroy_all
  end

  def notify_leftronic_vulcain_test_semaphore
    if self.vulcain_test_pass_changed?
      Leftronic.new.notify_vulcain_test_semaphore(self)
    end
  end
end
