class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
  attr_accessible :image_url, :brand, :name, :availability, :reference
  attr_accessible :availability_text, :price_text, :price_shipping_text, :price_strikeout_text
  attr_accessor :availability_text, :price_text, :price_shipping_text, :price_strikeout_text
  
  before_validation :parse_price
  before_validation :parse_price_shipping
  before_validation :parse_price_strikeout
  before_validation :parse_available
  before_validation :crop_shipping_info
  before_validation :sanitize_description

  SANITIZED_CONFIG = {
    :elements => %w[
      b blockquote br dd dl
      dt em h1 h2 h3 h4 h5 h6 i li
      ol p pre strike strong table tbody td
      tfoot th thead tr u ul
    ],

    :attributes => {
      'td'         => ['colspan', 'rowspan'],
      'th'         => ['colspan', 'rowspan']
    }
  }  

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
    self.price = parse_float(self.price_text) unless self.price_text.blank?
  end

  def parse_price_shipping
    self.price_shipping = parse_float(self.price_shipping_text) unless self.price_shipping_text.blank?
  end
  
  def parse_price_strikeout
    self.price_strikeout = parse_float(self.price_strikeout_text) unless self.price_strikeout_text.blank?
  end
  
  def parse_available
    return if self.availability_text.nil?
    result = true
    a = self.availability_text.unaccent.downcase
    if a =~ /out of stock/
      result = false
    end
    self.available = result
    true
  end
  
  def sanitize_description
    return if self.description.nil?
    doc = Nokogiri::HTML(self.description)
    doc.search('style').each { |node| node.remove }

    html = Sanitize.clean(doc.to_s, SANITIZED_CONFIG).gsub(/[\n\s]+/, " ").strip

    self.description = html
  end
   
end
