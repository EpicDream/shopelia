class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  has_many :order_items
  
  validates :user, :presence => true
  validates :state_name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  attr_accessible :user_id, :merchant_id, :message, :price_product, :price_delivery, :price_total, :urls, :payment_card
  attr_accessor :urls, :payment_card
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_save :serialize_questions
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  
  def start
    result = Vulcain::Order.create(Vulcain::OrderSerializer.new(self).as_json[:order])
    assess(result, :ordering)
  end

  def process verb, content
    begin
      if verb.eql?("message")
        self.message = content["message"]

      elsif verb.eql?("failure")
        fail(content["message"])

      elsif verb.eql?("assess")
        @questions = content["questions"]
        self.state = :pending_confirmation
        self.price_total = content["billing"]["price"]
        self.price_delivery = content["billing"]["shipping"]
        (content["products"] || []).each do |product|
          self.order_items.where(:product_id => Product.find_by_url(product["url"]).id).first.update_attributes(product.except("url"))
        end

      elsif verb.eql?("ask")
        @questions = content["questions"]
        self.state = :pending_answer

      elsif verb.eql?("answer")
        @questions.each { |question| question["answer"] = content[question["id"]] }
        result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        assess(result, :ordering)

      elsif verb.eql?("confirm")
        self.payment_card = self.user.payment_cards.where(:id => content["payment_card_id"]).first
        if self.payment_card.present?
          @questions.each { |question| question["answer"] = self.payment_card.present? ? true : false }
          result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
          assess(result, :finalizing)
        else
          fail("Cannot process payment, no credit card found for user")
        end

      elsif verb.eql?("cancel")
        @questions.each { |question| question["answer"] = false }
        result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        assess(result, :canceled)

      end
    rescue Exception => e
      fail("Error parsing callback data\n#{e.inspect}")
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
  
  def questions= questions
    @questions = questions
  end
  
  private
 
  def assess result, state
    if result.has_key?("Error")
      fail(result['Error'])
    else
      self.state = state
    end
    self.save
  end

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
      self.save
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
