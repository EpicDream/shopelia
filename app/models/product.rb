class Product < ActiveRecord::Base
  belongs_to :product_master
  belongs_to :merchant
  has_many :events
  has_many :product_versions
  
  validates :merchant, :presence => true
  validates :product_master, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :clean_url
  before_validation :extract_merchant_from_url
  before_validation :create_product_master
  before_save :truncate_name
  after_create :create_version
  
  scope :viking_pending, lambda { joins(:events).where("(products.versions_expires_at is null or products.versions_expires_at < ?) and events.created_at > ?", Time.now, 12.hours.ago) }
  
  def self.fetch url
    Product.find_or_create_by_url(Linker.clean(url)) unless url.nil?
  end
  
  def self.viking_shift
    Product.viking_pending.order("events.created_at desc").first
  end
  
  def versions_expired?
    self.versions_expires_at.nil? || self.versions_expires_at < Time.now
  end
  
  private
  
  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end
  
  def clean_url
    self.url = Linker.clean(self.url) unless self.url.nil?
  end
  
  def extract_merchant_from_url
    if self.merchant_id.nil? && self.url.present?
      merchant = Merchant.from_url(url)
      if merchant.nil?
        puts url
        self.errors.add(:base, I18n.t('products.errors.invalid_url', :url => url))
      else
        self.merchant_id = merchant.id
      end
    end
  end
  
  def create_version
    ProductVersion.create(product_id:self.id) if self.product_versions.empty?
  end
  
  def create_product_master
    self.product_master_id = ProductMaster.create.id if self.product_master_id.nil?
  end
  
end
