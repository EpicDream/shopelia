class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  has_many :order_items
  
  validates :user, :presence => true
  validates :state_name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  attr_accessible :user_id, :merchant_id, :message, :price_product, :price_delivery, :price_total, :urls
  attr_accessor :urls, :answer
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_save :serialize_questions
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  
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
    elsif verb.eql?("ask")
      @questions = content["questions"]
      self.state = :pending_answer
      (content["products"] || []).each do |product|
        self.order_items.where(:product_id => Product.find_by_url(product["url"]).id).first.update_attributes(product.except("url"))
      end
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
  
  def questions
    @questions
  end
  
  private

  def fail content
    self.message = content
    self.state = :error
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
  
  def prepare_order_items
    (self.urls || []).each do |url|
      product = Product.find_or_create_by_url(url)
      next if product.nil? || self.merchant_id && self.merchant_id != product.merchant_id
      self.merchant_id = product.merchant_id
      OrderItem.create(order:self, product:product)
    end
  end
  
  def serialize_questions
    self.questions_json = (@questions || []).to_json
  end
  
  def deserialize_questions
    @questions = JSON.parse(self.questions_json || "[]")
  end
  
end
