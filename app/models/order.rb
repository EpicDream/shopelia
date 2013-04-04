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
  
  def advance payload={}
    if payload["status"].eql?("error")
      self.state = :error
    else
      case self.state
      when :pending
        self.state = :ordering
        Vulcain::Order.create({:context => context, :data => { :product_url => self.product.url}})
      when :ordering
        self.state = :pending_confirmation
      when :pending_confirmation
        if payload["response"].eql?("ok")
          self.state = :paying
          Vulcain::Payment.create({:context => context})
        else
          self.state = :canceled
        end
      when :paying
        self.state = :success
      when :canceled
      when :success
      when :error
      end
    end
    self.save     
  end

  def state
    self.state_name.to_sym
  end
  
  private
  
  def context
    { :uuid => uuid, :callback_url => callback_url, :state => state }
  end
  
  def state= state_sym
    self.state_name = state_sym.to_s
  end
  
  def callback_url
    "http://api.shopelia.fr/api/orders/#{self.uuid}"
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
