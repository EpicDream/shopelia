class LookProduct < ActiveRecord::Base
  attr_accessible :look_id, :product_id, :code, :brand, :url, :feed
  attr_accessor :url, :feed
  
  belongs_to :look, touch:true
  belongs_to :product
  has_many :vendor_products, dependent: :destroy
  
  validates :look_id, :presence => true
  validates :product_id, :uniqueness => { :scope => :look_id }, :allow_nil => true
  validates :code, presence:true, :uniqueness => { :scope => [:brand, :look_id] }

  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }
  before_validation :ensure_brand_or_product

  after_create :create_hashtags_and_assign_to_look
  after_update :update_hashtag, if: -> { brand_changed? }
  before_create :assign_uuid
  
  def self.codes
    I18n.t('flink.products').keys.sort
  end

  def create_hashtags_and_assign_to_look
    return true unless self.code && self.brand
    strings = [self.brand]
    strings += [:en, :fr].map { |locale| I18n.t("flink.products.#{self.code}", locale: locale) }
    self.look.hashtags << Hashtag.find_or_create_from_strings(strings)
  end
  
  def update_hashtag
    Hashtag.update_with_name(brand_was, self.brand)
  end
  
  private

  def assign_uuid
    self.uuid = SecureRandom.hex(4)
  end
  
  def check_url_validity
    raise if self.url !~ /^http/
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.collections.add.invalid_url'))
  end

  def find_or_create_product
    self.product_id = Product.fetch(self.url).id
  end

  def ensure_brand_or_product
    self.errors.add(:base, 'Requires product or band') if self.product_id.nil? && self.brand.blank?
  end
end