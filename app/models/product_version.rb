# -*- encoding : utf-8 -*-
class ProductVersion < ActiveRecord::Base

  AVAILABILITY = "#{Rails.root}/lib/config/availability.yml"

  belongs_to :product, :touch => true
  has_many :order_items
  has_many :cart_items
  
  validates :product, :presence => true
  validates :size, :uniqueness => {:scope => [:product_id, :color]}, :allow_nil => true
  
  attr_accessible :description, :size, :color, :price, :price_shipping
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available
  attr_accessible :image_url, :brand, :name, :available, :reference
  attr_accessible :availability_text, :price_text, :price_shipping_text, :price_strikeout_text
  attr_accessor :availability_text, :price_text, :price_shipping_text, :price_strikeout_text

  before_save :truncate_name  
  before_validation :parse_price, :if => Proc.new { |v| v.price_text.present? }
  before_validation :parse_price_shipping, :if => Proc.new { |v| v.price_shipping_text.present? }
  before_validation :parse_price_strikeout, :if => Proc.new { |v| v.price_strikeout_text.present? }
  before_validation :parse_available, :if => Proc.new { |v| v.availability_text.present? }
  before_validation :sanitize_description, :if => Proc.new { |v| v.description.present? }
  before_validation :crop_shipping_info
  before_destroy :check_not_related_to_any_order

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
      if m = str.match(/^[^\d]*(\d+)[^\d](\d\d\d) ?[^\d] ?(\d+)/)
        m[1].to_f * 1000 + m[2].to_f + m[3].to_f / 100
      elsif m = str.match(/^[^\d]*(\d+)[^\d](\d\d\d)/)
        m[1].to_f * 1000 + m[2].to_f
      elsif m = str.match(/^[^\d]*(\d+)[^\d]*$/) || m = str.match(/^[^\d]*(\d+)[^\d]{1,2}(\d+)/)
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
    generate_incident "Shipping price too high : #{self.price_shipping_text}" if self.price_shipping.to_f > 150 && self.price_shipping.to_f > self.price.to_f / 3.0
  end
  
  def parse_price_strikeout
    self.price_strikeout = parse_float(self.price_strikeout_text)
  end
  
  def parse_available
    result = nil
    a = self.availability_text.unaccent.downcase
    dic = YAML.load(File.open(AVAILABILITY))
    key = dic.keys.detect {|key| key if a =~ /#{key}/ }
    generate_incident "Cannot parse availability : #{a}" if key.nil?
    self.available = key.nil? ? true : dic[key]
    true
  end
  
  def sanitize_description
    doc = Nokogiri::HTML(self.description)
    doc.search('style').each { |node| node.remove }
    doc.search('noscript').each { |node| node.remove }

    html = Sanitize.clean(doc.to_s, SANITIZED_CONFIG).gsub(/[\n\s]+/, " ")
    html = html.gsub("Afficher plus", "")
    html = html.gsub("Réduire", "")

    self.description = html.strip
  end
   
  def check_not_related_to_any_order
    self.order_items.empty?
  end

  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end   
end
