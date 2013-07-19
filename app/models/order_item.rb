class OrderItem < ActiveRecord::Base
  belongs_to :product_version
  belongs_to :order
  has_one :product, :through => :product_version
  
  validates :product_version, :presence => true
  validates :order, :presence => true
  
  alias_attribute :price_product, :price
  alias_attribute :product_price, :price
end
