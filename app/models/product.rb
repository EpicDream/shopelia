class Product < ActiveRecord::Base
  belongs_to :merchant
  has_many :orders
  
  validates :merchant, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :extract_merchant_from_url
  before_validation :monetize_url
  before_save :truncate_name
  
  def self.fetch url
    Product.find_or_create_by_url(Linker.monetize(url)) unless url.nil?
  end
  
  private
  
  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end
  
  def monetize_url
    self.url = Linker.monetize(self.url) unless self.url.nil?
  end
  
  def extract_merchant_from_url
    if self.merchant_id.nil?
      merchant = Merchant.from_url(url)
      if merchant.nil?
        self.errors.add(:base, I18n.t('products.errors.unsupported_merchant'))
      else
        self.merchant_id = merchant.id
      end
    end
  end
  
end
