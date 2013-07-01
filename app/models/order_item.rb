class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  
  validates :product, :presence => true
  validates :order, :presence => true
  
  alias_attribute :price_product, :product_price
  alias_attribute :price_delivery, :shipping_price
  alias_attribute :delivery_text, :shipping_info
end
