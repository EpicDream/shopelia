class LookProduct < ActiveRecord::Base
  belongs_to :look
  belongs_to :product

  CODES = "#{Rails.root}/lib/config/product_codes.yml"

  validates :look_id, :presence => true
  validates :product_id, :uniqueness => { :scope => :look_id }, :allow_nil => true

  attr_accessible :look_id, :product_id, :code, :brand, :url, :feed
  attr_accessor :url, :feed

  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }
  before_validation :build_from_feed, if:Proc.new{ |item| item.feed.present? }
  before_validation :ensure_brand_or_product

  def self.codes
    dic = YAML.load(File.open(CODES))
    dic["codes"].sort
  end

  private

  def check_url_validity
    raise if self.url !~ /^http/
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.collections.add.invalid_url'))
  end

  def find_or_create_product
    self.product_id = Product.fetch(self.url).id
  end

  def build_from_feed
    product = Product.fetch(feed[:product_url])
    version = {}
    version[:price] = "#{sprintf("%.2f", feed[:price].to_f / 100)} #{feed[:currency]}"
    version[:price_shipping] = "#{sprintf("%.2f", feed[:price_shipping].to_f / 100)} #{feed[:currency]}"
    version[:description] = feed[:description]
    version[:name] = feed[:name]
    version[:brand] = feed[:brand]
    version[:shipping_info] = feed[:shipping_info]
    version[:availability] = "En stock"
    version[:image_url] = feed[:image_url]
    product.versions = [ version ]
    product.options_completed = true
    product.save
    product.update_column "versions_expires_at", 6.months.from_now
    self.product_id = product.id
  end

  def generate_event    
    self.product.authorize_push_channel
    EventsWorker.perform_async({
      :product_id => self.product_id,
      :action => Event::REQUEST,
      :tracker => "look"
    }) if self.product.merchant.mapping_id.present?
  end

  def ensure_brand_or_product
    self.errors.add(:base, 'Requires product or band') if self.product_id.nil? && self.brand.blank?
  end
end