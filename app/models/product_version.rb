class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
  attr_accessible :image_url, :brand, :name, :availability
  attr_accessor :availability, :price, :price_shipping, :price_strikeout
  
  before_validation :parse_price
  before_validation :parse_price_shipping
  before_validation :parse_price_strikeout
  before_validation :parse_available
  before_validation :crop_shipping_info
  
  private

  def parse_float str
    str = str.downcase
    if str =~ /gratuit/ || str =~ /free/ || str =~ /offert/
      0.0
    else
      if m = str.match(/^[^\d]*(\d+)[^\d]*$/) || m = str.match(/^[^\d]*(\d+)[^\d]{1,2}(\d+)/)
        result = m[1].to_f + m[2].to_f / 100
        if result > 50
          generate_incident "Shipping price too high : #{str}"
        else
          result
        end
      else 
        generate_incident "Cannot parse price : #{str}"
      end
    end
  end
  
  def generate_incident str
    Incident.create(
      :issue => "Viking",
      :description => str,
      :resource_type => 'Product',
      :resource_id => self.product.id,
      :severity => Incident::IMPORTANT)
    nil
  end
            
  def crop_shipping_info
    self.shipping_info = self.shipping_info[0..249] if self.shipping_info && self.shipping_info.length > 250
  end

  def parse_price
    self.price = parse_float(self.price.to_s) unless self.price.nil?
  end

  def parse_price_shipping
    self.price_shipping = parse_float(self.price_shipping.to_s) unless self.price_shipping.nil?
  end
  
  def parse_price_strikeout
    self.price_strikeout = parse_float(self.price_strikeout.to_s) unless self.price_strikeout.nil?
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
