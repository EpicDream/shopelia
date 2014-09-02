class VendorProduct < ActiveRecord::Base
  PURE_SHOPPING = "pureshopping"
  attr_accessible :similar, :staff_pick
  
  belongs_to :look_product
  
  validates :url, presence: true
  validates :vendor, presence: true
  
  def self.create_from_pure_shopping product_id, look_product, similar=false
    product = PureShoppingProduct.find_by_id product_id
    
    vendor_product = VendorProduct.new do |vp|
      vp.url = product.redirect_url
      vp.image_url = product.image_url
      vp.vendor = PURE_SHOPPING
      vp.product_id = product_id
      vp.similar = similar == 'true'
      vp.look_product_id = look_product.id 
    end
    
    vendor_product.save
  rescue
    Rails.logger.error("[VendorProduct#create_from_pure_shopping]#{product_id} - #{look_product.id}")
    false
  end
  
  def original
    @original ||= PureShoppingProduct.find_by_id self.product_id
  end
  
end