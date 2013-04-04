class Product < ActiveRecord::Base
  belongs_to :merchant
  has_many :orders
  
  validates :merchant, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :extract_merchant_from_url
  
  private
  
  def extract_merchant_from_url
    if self.merchant_id.nil?
      merchant = Merchant.where("url like ?", "http://#{URI.parse(url).host}%").first
      if merchant.nil?
        self.errors.add(:base, I18n.t('products.merchant_not_supported'))
        false
      else
        self.merchant_id = merchant.id
      end        
    end
  end
end
