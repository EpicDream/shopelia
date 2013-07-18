class Product < ActiveRecord::Base
  belongs_to :merchant
  has_many :orders
  has_many :events
  
  validates :merchant, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :monetize_url
  before_validation :extract_merchant_from_url
  before_save :truncate_name
  
  scope :viking_pending, lambda { joins(:events).where("(products.last_checked_at is null or products.last_checked_at < ?) and events.created_at > ?", 1.hours.ago, 12.hours.ago) }
  
  def self.fetch url
    Product.find_or_create_by_url(Linker.monetize(url)) unless url.nil?
  end
  
  def self.viking_shift
    Product.viking_pending.order("events.created_at desc").first
  end
  
  private
  
  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end
  
  def monetize_url
    self.url = Linker.monetize(self.url) unless self.url.nil?
  end
  
  def extract_merchant_from_url
    if self.merchant_id.nil? && self.url.present?
      merchant = Merchant.from_url(url)
      if merchant.nil?
        self.errors.add(:base, I18n.t('products.errors.invalid_url', :url => url))
      else
        self.merchant_id = merchant.id
      end
    end
  end
  
end
