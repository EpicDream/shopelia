class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  
  validates :product, :presence => true
  validates :order, :presence => true
  
  alias_attribute :price_product, :price
  alias_attribute :product_price, :price
end
