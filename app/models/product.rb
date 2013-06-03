class Product < ActiveRecord::Base
  belongs_to :merchant
  has_many :orders
  
  validates :merchant, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :extract_merchant_from_url
  
  private
  
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
