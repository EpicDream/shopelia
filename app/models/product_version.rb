# -*- encoding : utf-8 -*-
class ProductVersion < ActiveRecord::Base

  belongs_to :product, :touch => true
  has_many :order_items
  has_many :cart_items
  has_many :product_images, :dependent => :destroy
  
  validates :product, :presence => true
  
  attr_accessible :description, :price, :price_shipping, :json_description
  attr_accessible :price_strikeout, :product_id, :shipping_info, :available, :rating
  attr_accessible :image_url, :brand, :name, :available, :reference
  attr_accessible :availability_text, :rating_text, :price_text, :price_shipping_text, :price_strikeout_text
  attr_accessible :option1, :option2, :option3, :option4, :images
  attr_accessor :availability_text, :rating_text, :price_text, :price_shipping_text, :price_strikeout_text, :images

  alias_attribute :size, :option1
  alias_attribute :color, :option2

  before_save :truncate_name  
  before_validation :parse_price, :if => Proc.new { |v| v.price_text.present? }
  before_validation :parse_price_shipping, :if => Proc.new { |v| v.price_shipping_text.present? }
  before_validation :parse_price_strikeout, :if => Proc.new { |v| v.price_strikeout_text.present? }
  before_validation :parse_available, :if => Proc.new { |v| v.availability_text.present? }
  before_validation :parse_rating, :if => Proc.new { |v| v.rating_text.present? }
  before_validation :sanitize_description, :if => Proc.new { |v| v.description.present? }
  before_validation :crop_shipping_info
  before_validation :prepare_options
  before_validation :assess_version
  before_destroy :check_not_related_to_any_order

  after_save :create_product_images, :if => Proc.new { |v| v.images.is_a?(Array) && v.images.count > 0 }
  after_update :notify_channel, :if => Proc.new { |v| v.available.present? }

  scope :available, where(available:true)

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

  def cashfront_value price, scope
    scope ||= {}
    scope[:merchant] = self.product.merchant
    rule = CashfrontRule.find_for_scope(scope)
    rule ? rule.rebate(price) : 0.0
  end

  def self.generate_option_md5 option
    return nil if option.nil?
    Digest::MD5.hexdigest(option["text"].present? ? option["text"].strip : option["src"])
  end

  def authorize_push_channel
    Nest.new("product-version")[self.id][:created_at].set(Time.now.to_i)
  end

  private

  def assess_version
    self.available = nil if self.available && (self.price.nil? || self.price_shipping.nil? || self.name.nil? || self.image_url.nil?)
    true
  end

  def prepare_options
    if self.option1.is_a?(Hash)
      if self.option1["text"].blank? && self.option1["src"].blank?
        generate_incident "Missing text or src for option1 : #{self.option1}"
        self.option1_md5 = self.option1 = nil
      else
        self.option1_md5 = ProductVersion.generate_option_md5(self.option1)
        self.option1 = Hash[self.option1.sort].to_json
      end
    end
    if self.option2.is_a?(Hash)
      if self.option2["text"].blank? && self.option2["src"].blank?
        generate_incident "Missing text or src for option2 : #{self.option2}"
        self.option2_md5 = self.option2 = nil
      else
        self.option2_md5 = ProductVersion.generate_option_md5(self.option2)
        self.option2 = Hash[self.option2.sort].to_json
      end
    end
    if self.option3.is_a?(Hash)
      if self.option3["text"].blank? && self.option3["src"].blank?
        generate_incident "Missing text or src for option3 : #{self.option3}"
        self.option3_md5 = self.option3 = nil
      else
        self.option3_md5 = ProductVersion.generate_option_md5(self.option3)
        self.option3 = Hash[self.option3.sort].to_json
      end
    end
    if self.option4.is_a?(Hash)
      if self.option4["text"].blank? && self.option4["src"].blank?
        generate_incident "Missing text or src for option4 : #{self.option4}"
        self.option4_md5 = self.option4 = nil
      else
        self.option4_md5 = ProductVersion.generate_option_md5(self.option4)
        self.option4 = Hash[self.option4.sort].to_json
      end
    end
  end

  def parse_float str
    res = MerchantHelper.parse_float(str)
    generate_incident "Cannot parse price : #{str}" if res.nil?
    res
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
    self.availability_info = self.availability_text
    res = MerchantHelper.parse_availability(self.availability_text, product.url)
    self.available = res[:avail]
    self.availability_info = MerchantHelper::AVAILABLE if res[:specific] && res[:avail]
    if self.available.nil?
      generate_incident "Cannot parse availability : #{self.availability_info}"
      self.available = true
    end
    true
  end

  def parse_rating
    self.rating = MerchantHelper.parse_rating(self.rating_text)
    true
  end
  
  def sanitize_description
    doc = Nokogiri::HTML(self.description)
    doc.search('style').each { |node| node.remove }
    doc.search('noscript').each { |node| node.remove }

    html = Sanitize.clean(doc.to_s, SANITIZED_CONFIG).gsub(/[\n\s]+/, " ")
    html = html.gsub("Afficher plus", "")
    html = html.gsub("Réduire", "")
    html = html.gsub("<h3>Amazon.fr</h3>", "")

    self.description = html.strip
  end
   
  def create_product_images
    self.product_images.destroy_all
    self.images.each do |url|
      ProductImage.create!(product_version_id:self.id,url:url)
    end
  end

  def check_not_related_to_any_order
    self.order_items.empty?
  end

  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end   

  def notify_channel
    ts = Nest.new("product-version")[self.id][:created_at].get.to_i  
    Pusher.trigger("product-version-#{self.id}", "update", ProductVersionSerializer.new(self, scope:{short:true}).as_json[:product_version]) if ts > Time.now.to_i - 60*5
  rescue
  end
end
