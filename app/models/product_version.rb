class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
  attr_accessible :image_url, :brand, :name, :availability
  attr_accessor :availability
  
  before_validation :parse_price
  before_validation :parse_price_shipping
  before_validation :parse_price_strikeout
  before_validation :parse_available
  
  def self.parse_float str
    str = str.downcase
    if str =~ /gratuit/ || str =~ /free/
      0.0
    else
      r = str.gsub(/[^\d\.,]/, "").gsub(",", ".")
      r.length > 0 && r =~ /\d+/ ? r.to_f : nil
    end
  end

  private
  
  def parse_price
    self.price = ProductVersion.parse_float(self.price.to_s)
  end

  def parse_price_shipping
    self.price_shipping = ProductVersion.parse_float(self.price_shipping.to_s)
  end
  
  def parse_price_strikeout
    self.price_strikeout = ProductVersion.parse_float(self.price_strikeout.to_s)
  end
  
  def parse_available
    return if self.availability.nil?
    result = true
    a = self.availability.unaccent.downcase
    if a =~ /out of stock/
      result = false
    end
    self.available = result
    true
  end
  
end
