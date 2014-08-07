class PureShoppingProduct
  CATEGORIES = YAML.load_file("#{Rails.root}/lib/crawlers/pureshopping/categories.yml").invert
  
  include MongoMapper::Document
  timestamps!
  PureShoppingProduct.create_index('name')
  PureShoppingProduct.create_index('_brand_name')
  
  def self.similar_to look_product
    pattern_1 = Regexp.escape(look_product.brand)
    pattern_2 = Regexp.escape(look_product.brand.gsub(/\s+/, ''))
    where(:_brand_name => /#{pattern_1}|#{pattern_2}/i)
  rescue => e
    Rails.logger.error("[PureShoppingProduct#similar_to][#{look_product.brand}] #{e}")
    []
  end
  
  def self.filter_on category_id=nil, keyword=nil
    pattern = Regexp.new(keyword || '', true)
    
    unless category_id.blank?
      where(:$or => [ {name: pattern}, {_brand_name: pattern} ], :$and => [category_id: category_id.to_i])
    else
      where(:$or => [ {name: pattern}, {_brand_name: pattern} ])
    end
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