class ProductVersion < ActiveRecord::Base
  belongs_to :product
  
  validates :product, :presence => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
  attr_accessible :image_url, :brand, :name, :available, :reference
  attr_accessible :availability_text, :price_text, :price_shipping_text, :price_strikeout_text
  attr_accessor :availability_text, :price_text, :price_shipping_text, :price_strikeout_text
  
  before_validation :parse_price, :if => Proc.new { |v| v.price_text.present? }
  before_validation :parse_price_shipping, :if => Proc.new { |v| v.price_shipping_text.present? }
  before_validation :parse_price_strikeout, :if => Proc.new { |v| v.price_strikeout_text.present? }
  before_validation :parse_available, :if => Proc.new { |v| v.availability_text.present? }
  before_validation :sanitize_description, :if => Proc.new { |v| v.description.present? }
  before_validation :crop_shipping_info

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
        m[1].to_f + m[2].to_f / 100
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
    self.price = parse_float(self.price_text)
  end

  def parse_price_shipping
    self.price_shipping = parse_float(self.price_shipping_text)
    generate_incident "Shipping price too high : #{self.price_shipping_text}" if self.price_shipping.to_f > 50
  end
  
  def parse_price_strikeout
    self.price_strikeout = parse_float(self.price_strikeout_text)
  end
  
  def parse_available
    a = self.availability_text.unaccent.downcase
    if a =~ /out of stock/ || \
       a =~ /aucun vendeur ne propose ce produit/ || \
       a =~ /en rupture de stock/ || \
       a =~ /sur commande/
      result = false
    elsif a =~ /en stock/ || a=~ /^\(\d+\)$/ || a=~ /expedie sous/
      result = true
    else
      generate_incident "Cannot parse availability : #{a}"
      result = true
    end
    self.available = result
    true
  end
  
  def sanitize_description
    doc = Nokogiri::HTML(self.description)
    doc.search('style').each { |node| node.remove }

    html = Sanitize.clean(doc.to_s, SANITIZED_CONFIG).gsub(/[\n\s]+/, " ").strip

    self.description = html
  end
   
end
