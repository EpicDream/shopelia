class CartItem < ActiveRecord::Base
  belongs_to :cart, :touch => true
  belongs_to :product_version
  has_one :product, :through => :product_version
  belongs_to :developer

  validates :cart, :presence => true
  validates :developer, :presence => true
  validates :uuid, :presence => true, :uniqueness => true
  validates :product_version_id, :presence => true, :uniqueness => { :scope => :cart_id }

  attr_accessible :cart_id, :product_version_id, :developer_id, :tracker, :monitor, :url
  attr_accessor :url
  
  before_validation :initialize_uuid
  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }

  after_create :save_prices
  after_create :notify_creation_to_user, if:Proc.new{ |item| item.cart.kind == Cart::FOLLOW }
  after_create :notify_creation_to_admin, if:Proc.new{ |item| item.cart.kind == Cart::FOLLOW }
  
  def to_param
    self.uuid
  end

  def unsubscribe
    self.update_attribute :monitor, false
  end

  private

  def check_url_validity
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.cart_items.bad_url'))
  end
  
  def find_or_create_product
    product = Product.fetch(self.url)
    self.product_version_id = product.product_versions.first.id
  end

  def save_prices
    self.price = self.product_version.price
    self.price_shipping = self.product_version.price_shipping
    self.save
  end

  def initialize_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end

  def notify_creation_to_user
    Emailer.notify_cart_item_creation(self).deliver
  end
  
  def notify_creation_to_admin
    Emailer.notify_admin_cart_item_creation(self).deliver
  end
end
