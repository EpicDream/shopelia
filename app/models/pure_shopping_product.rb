class PureShoppingProduct
  include MongoMapper::Document
  timestamps!
  PureShoppingProduct.create_index('name')
  PureShoppingProduct.create_index('_brand_name')
  
  def self.similar_to look_product
    brand_pattern = Regexp.escape(look_product.brand)
    where(:_brand_name => /#{brand_pattern}/)
  end
  
  def redirect_url
    _redirect.gsub(/\/sg\/10/, '/ns/541')
  end
  
  def brand
    _brand_name
  end
  
  def image_url
    default_picture_orig
  end
end