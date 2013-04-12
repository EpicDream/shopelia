class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  belongs_to :product
  
  validates :user, :presence => true
  validates :product, :presence => true
  validates :state_name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  attr_accessible :user_id, :merchant_id, :product_id, :message, :price_product, :price_delivery, :price_total, :url
  attr_accessor :url
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :prepare_product
  
  def start
    result = Vulcain::Order.create(Vulcain::OrderSerializer.new(self).as_json[:order])
    self.state = result.has_key?("Error") ? fail(result['Error']) : :ordering
    self.save
  end

  def process verb, content
    if verb.eql?("message")
      self.message = content
    elsif verb.eql?("failure")
      fail(content)
    end
    self.save
  end

  def state
    self.state_name.to_sym
  end

  def callback_url
    #"http://api.shopelia.fr/api/callbacks/orders/#{self.uuid}"
    "http://zola.epicdream.fr:4444/api/callback/orders/#{self.uuid}"
  end
  
  private

  def fail content
    self.message = content
    self.state = :error
  end

  def parse_price str=""
    if str =~ /^(\d+)[,\.](\d+)/
      $1.to_f + $2.to_f/100
    else
      0
    end
  end
  
  def state= state_sym
    self.state_name = state_sym.to_s
  end
  
  def initialize_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
  
  def initialize_state
    self.state = :pending if self.state_name.nil?
  end
  
  def prepare_product
    if self.url
      product = Product.find_by_url(self.url)
      if product.nil?
        product = Product.new(:url => self.url)
        if !product.save
          self.errors.add(:base, I18n.t('products.merchant_not_supported'))
          return false
        end
      end
      self.product_id = product.id
      self.merchant_id = product.merchant_id
    end
  end
  
end
