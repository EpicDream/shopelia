class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
end
