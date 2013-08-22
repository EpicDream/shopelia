class CartItem < ActiveRecord::Base
  belongs_to :cart, :touch => true
  belongs_to :product_version

  validates :cart, :presence => true
  validates :uuid, :presence => true, :uniqueness => true
  validates :product_version_id, :presence => true, :uniqueness => { :scope => :cart_id }

  attr_accessible :cart_id, :product_version_id
  
  before_validation :initialize_uuid
  after_create :save_prices
  
  private
  
  def save_prices
    self.price = self.product_version.price
    self.price_shipping = self.product_version.price_shipping
    self.save
  end

  def initialize_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
  
end
