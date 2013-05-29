class Order < ActiveRecord::Base
  STATES = ["initialized", "processing", "pending", "completed", "aborted"]

  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  belongs_to :merchant_account
  belongs_to :payment_card
  has_many :order_items
  
  validates :user, :presence => true
  validates :state_name, :presence => true, :inclusion => { :in => STATES }
  validates :uuid, :presence => true, :uniqueness => true
  validates :address, :presence => true
  validates :expected_price_total, :presence => true
  validates :payment_card, :presence => true

  attr_accessible :user_id, :merchant_id, :address_id, :merchant_account_id, :payment_card_id
  attr_accessible :message, :urls, :shipping_info
  attr_accessible :expected_price_product, :expected_price_shipping, :expected_price_total
  attr_accessible :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attr_accessible :billed_price_product, :billed_price_shipping, :billed_price_total
  attr_accessor :urls
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :initialize_merchant_account
  before_validation :clear_message
  before_save :serialize_questions
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  after_create :notify_user
  after_create :start
  
  def start
    @questions = []
    error_code = message = nil
    self.state = :processing
    assess Vulcain::Order.create(Vulcain::OrderSerializer.new(self).as_json[:order])
    self.save!
  end

  def restart
    if self.retry_count.to_i < Rails.configuration.max_retry
      self.merchant_account_id = MerchantAccount.create(user_id:self.user_id, merchant_id:self.merchant_id, address_id:self.address_id).id
      self.retry_count = self.retry_count.to_i + 1
      start
    else
      fail(I18n.t("orders.failure.account"), :account_error)
    end
    self.save!
  end

  def process verb, content
    begin
      if verb.eql?("message")
        self.message = content["message"]
        if self.message.eql?("account_created")
          self.merchant_account.confirm_creation!
        end

      elsif verb.eql?("failure")
        case content["message"]
        when "exception" then fail(content["message"], :vulcain_exception)
        when "no_idle" then fail(content["message"], :vulcain_error)
        when "error" then fail(content["message"], :vulcain_error)
        when "driver_failed" then fail("driver_failure", :vulcain_error)
        when "order_canceled" then fail("order_canceled", :user_error)
        when "order_validation_failed" then abort(:payment_refused)
        when "account_creation_failed" then restart
        when "login_failed" then restart
        end

      elsif verb.eql?("assess")
        @questions = content["questions"]
        self.prepared_price_total = content["billing"]["total"]
        self.prepared_price_product = content["billing"]["product"]
        self.prepared_price_shipping = content["billing"]["shipping"]
        (content["products"] || []).each do |product|
          self.order_items.where(:product_id => Product.find_by_url(product["url"]).id).first.update_attributes(product.except("url"))
        end
        confirmed = self.expected_price_total == self.prepared_price_total
        @questions.each { |question| question["answer"] = confirmed }
        assess Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        abort(:price_range) unless confirmed

      elsif verb.eql?("success")
        self.billed_price_total = content["billing"]["total"]
        self.billed_price_product = content["billing"]["product"]
        self.billed_price_shipping = content["billing"]["shipping"]
        self.shipping_info = content["billing"]["shipping_info"]
        self.state = :completed

      end
    rescue Exception => e
      puts e.inspect
      fail("Error parsing callback data\n#{e.inspect}", :vulcain_api)
    end
    self.save!
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
 
  def assess result
    fail(result['Error'], :vulcain_api) if result.has_key?("Error")
  end

  def fail content, error_sym
    self.message = content
    self.error_code = error_sym.to_s
    self.state = :pending
  end

  def abort error_sym
    self.error_code = error_sym.to_s
    self.state = :aborted
  end    

  def state= state_sym
    self.state_name = state_sym.to_s
  end
  
  def initialize_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end
  
  def initialize_state
    self.state = :initialized if self.state_name.nil?
  end
  
  def clear_message
    self.message = nil if self.state != :processing && self.state != :pending
  end
  
  def initialize_merchant_account
    self.merchant_account_id = MerchantAccount.find_or_create_for_order(self).id if self.merchant_account_id.nil?
  end
  
  def prepare_order_items
    (self.urls || []).each do |url|
      product = Product.find_or_create_by_url(url)
      next if product.nil? || self.merchant_id && self.merchant_id != product.merchant_id
      self.merchant_id = product.merchant_id
      self.save!
      OrderItem.create!(order:self, product:product)
    end
  end
  
  def serialize_questions
    self.questions_json = (@questions || []).to_json
  end
  
  def deserialize_questions
    @questions = JSON.parse(self.questions_json || "[]")
  end
  
  def notify_user
    Emailer.notify_order_creation(self).deliver
  end
  
end
