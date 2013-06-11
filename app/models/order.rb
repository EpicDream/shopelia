class Order < ActiveRecord::Base
  STATES = ["initialized", "processing", "pending", "querying", "completed", "failed"]
  ERRORS = ["vulcain_api", "vulcain", "payment", "user", "account"]

  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  belongs_to :merchant_account
  belongs_to :payment_card
  has_many :order_items, :dependent => :destroy
  
  validates :user, :presence => true
  validates :state_name, :presence => true, :inclusion => { :in => STATES }
  validates :uuid, :presence => true, :uniqueness => true
  validates :address, :presence => true
  validates :expected_price_total, :presence => true
  validates :payment_card, :presence => true

  attr_accessible :user_id, :address_id, :merchant_account_id, :payment_card_id
  attr_accessible :message, :products, :shipping_info, :should_auto_cancel, :confirmation
  attr_accessible :expected_price_product, :expected_price_shipping, :expected_price_total
  attr_accessible :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attr_accessible :billed_price_product, :billed_price_shipping, :billed_price_total
  attr_accessor :products, :confirmation
  
  scope :delayed, lambda { where("state_name='pending' and created_at < ?", Time.zone.now - 3.minutes ) }
  scope :expired, lambda { where("state_name='pending' and created_at < ?", Time.zone.now - 4.hours ) }
  scope :canceled, lambda { where("state_name='querying' and created_at < ?", Time.zone.now - 2.hours ) }
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :initialize_merchant_account
  before_validation :clear_message
  before_save :serialize_questions
  before_create :validates_products
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  after_create :start, :if => Proc.new { |order| !order.destroyed? }
  after_update :notify_leftronic
  
  def to_param
    self.uuid
  end
  
  def start
    return false unless [:initialized, :pending, :querying].include?(state)
    self.reload
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
      self.state = :pending
      start
    else
      fail(I18n.t("orders.failure.account"), :account)
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
        case content["status"]
        when "exception" then fail("exception", :vulcain)
        when "no_idle" then fail("no_idle", :vulcain)
        when "error" then fail("error", :vulcain)
        when "driver_failed" then fail("driver_failed", :vulcain)
        when "order_timeout" then fail("order_timeout", :vulcain)
        when "uuid_conflict" then fail("uuid_conflict", :vulcain)
        when "dispatcher_crash" then fail("dispatcher_crash", :vulcain)
        when "order_validation_failed" then abort(:payment)
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
        confirmed = self.expected_price_total >= self.prepared_price_total
        @questions.each { |question| question["answer"] = confirmed }
        assess Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
        query unless confirmed

      elsif verb.eql?("success")
        self.billed_price_total = content["billing"]["total"]
        self.billed_price_product = content["billing"]["product"]
        self.billed_price_shipping = content["billing"]["shipping"]
        self.shipping_info = content["billing"]["shipping_info"]
        self.error_code = nil
        self.state = :completed
        Emailer.notify_order_success(self).deliver

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
  
  def time_out
    abort
    self.save!
  end
  
  def cancel
    abort :user
    self.save!
  end
  
  def confirm
    self.expected_price_total = self.prepared_price_total
    self.prepared_price_total = nil
    self.prepared_price_product = nil
    self.prepared_price_shipping = nil
    start
  end
  
  def notify_creation
    return unless self.notification_email_sent_at.nil?
    Emailer.notify_order_creation(self).deliver
    self.update_attribute :notification_email_sent_at, Time.now
  end
  
  private
 
  def assess result
    fail(result['Error'], :vulcain_api) if result.has_key?("Error")
  end

  def query
    self.state = :querying
    Emailer.notify_order_price_change(self).deliver
  end

  def fail content, error_sym
    self.message = content
    self.error_code = check_error_validity(error_sym.to_s)
    self.state = :pending
  end

  def abort error_sym=nil
    self.error_code = check_error_validity(error_sym.to_s) unless error_sym.nil?
    self.state = :failed
    Emailer.notify_order_failure(self).deliver
  end

  def check_error_validity error
    ERRORS.include?(error) ? error : "INVALID_ERROR"
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
  
  def validates_products  
    if self.products.nil? || self.products.count == 0
      self.errors.add(:base, I18n.t('orders.errors.no_product'))
    else
      self.products.each do |p|
        product = Product.fetch(p[:url])

        self.errors.add(
          :base, I18n.t('orders.errors.invalid_product', 
          :error => product.nil? ? "" : product.errors.full_messages.join(","))) and next if product.nil? || !product.persisted?

        product.name = p[:name] unless p[:name].blank?
        product.image_url = p[:image_url] unless p[:image_url].blank?
        self.errors.add(:base, I18n.t('orders.errors.invalid_product', :error => product.errors.full_messages.join(","))) if !product.save
      end
    end
    self.errors.count == 0
  end
  
  def prepare_order_items
    self.products.each do |p|
      product = Product.fetch(p[:url])
      if product.nil? || !product.persisted? || self.merchant_id && self.merchant_id != product.merchant_id
        self.destroy and return
      end
      self.merchant_id = product.merchant_id
      self.save
      order = OrderItem.create!(order:self, product:product)
    end
  end
  
  def serialize_questions
    self.questions_json = (@questions || []).to_json
  end
  
  def deserialize_questions
    @questions = JSON.parse(self.questions_json || "[]")
  end
  
  def notify_leftronic
    Leftronic.new.notify_order(self) if self.state_name_changed?
  end
  
end
