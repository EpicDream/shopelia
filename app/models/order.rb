class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  belongs_to :merchant_account
  has_many :order_items
  
  validates :user, :presence => true
  validates :state_name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true
  validates :address, :presence => true

  attr_accessible :user_id, :merchant_id, :address_id, :merchant_account_id
  attr_accessible :message, :price_product, :price_delivery, :price_total, :urls, :payment_card
  attr_accessor :urls, :payment_card
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :initialize_address
  before_validation :initialize_merchant_account
  before_save :serialize_questions
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  
  def start
    result = Vulcain::Order.create(Vulcain::OrderSerializer.new(self).as_json[:order])
    assess(result, :ordering)
  end

  def restart
    if self.retry_count.to_i < Rails.configuration.max_retry
      self.merchant_account_id = MerchantAccount.create(user_id:self.user_id, merchant_id:self.merchant_id, address_id:self.address_id).id
      self.retry_count = self.retry_count.to_i + 1
      start
    else
      fail(I18n.t("orders.failure.account"), :account_error)
    end
  end

  def process verb, content
    begin
      if verb.eql?("message")
        self.message = content["status"]
        if self.message.eql?("account_created")
          self.merchant_account.update_attribute :merchant_created, true
        end

      elsif verb.eql?("failure")
        case content["status"]
        when "exception" then fail(content["message"], :vulcain_exception)
        when "no_idle" then fail(content["message"], :vulcain_error)
        when "error" then fail(content["message"], :vulcain_error)
        when "driver_failed" then fail(content["message"], :vulcain_error)
        when "order_canceled" then fail("order_canceled", :user_error)
        when "order_validation_failed" then fail(I18n.t("orders.failure.payment"), :payment_error)
        when "account_creation_failed" then restart
        when "login_failed" then restart
        end

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

      elsif verb.eql?("answer") && @questions.size > 0
        @questions.each { |question| question["answer"] = content[question["id"]] }
        result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        assess(result, :ordering)

      elsif verb.eql?("confirm") && @questions.size > 0
        self.payment_card = self.user.payment_cards.where(:id => content["payment_card_id"]).first
        if self.payment_card.present?
          @questions.each { |question| question["answer"] = self.payment_card.present? ? true : false }
          result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
          assess(result, :finalizing)
        else
          fail("Cannot process payment, no credit card found for user", :user_error)
        end

      elsif verb.eql?("cancel") && @questions.size > 0
        @questions.each { |question| question["answer"] = false }
        result = Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        assess(result, :canceling)

      elsif verb.eql?("success")
        self.state = :success

      end
    rescue Exception => e
      fail("Error parsing callback data\n#{e.inspect}", :vulcain_api)
    end
    self.save
  end
  
  def state
    self.state_name.to_sym
  end

  def callback_url
    "#{Rails.configuration.host}/api/callback/orders/#{self.uuid}"
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
      fail(result['Error'], :vulcain_api)
    else
      self.state = state
    end
    self.save
  end

  def fail content, error_sym
    self.message = content
    self.error_code = error_sym.to_s
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
  
  def initialize_address
    if self.user.addresses.default.count > 0
      self.address_id = self.user.addresses.default.first.id if self.address_id.nil?
    else
      self.errors.add(:base, I18n.t('orders.no_address'))
    end
  end

  def initialize_merchant_account
    self.merchant_account_id = MerchantAccount.find_or_create_for_order(self).id if self.merchant_account_id.nil?
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
