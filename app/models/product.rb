class Product < ActiveRecord::Base
  belongs_to :merchant
  has_many :orders
  
  validates :merchant, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :extract_merchant_from_url
  before_create :set_shopelia_affiliate_id_for_amazon
  
  private
  
  def extract_merchant_from_url
    if self.merchant_id.nil?
      begin
        merchant = Merchant.where("url like ?", "http://#{URI.parse(url).host}%").first
        if merchant.nil?
          self.errors.add(:base, I18n.t('products.errors.unsupported_merchant'))
          false
        else
          self.merchant_id = merchant.id
        end
      rescue
        self.errors.add(:base, I18n.t('products.errors.invalid_url'))
      end
    end
  end
  
  def set_shopelia_affiliate_id_for_amazon
    self.url = self.url.gsub(/tag=[a-z0-9\-]+/, "tag=shopelia-21")
  end
end
