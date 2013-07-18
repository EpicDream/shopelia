class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :options, :price, :price_shipping, :price_strikeout, :product_id, :shipping_info
end
