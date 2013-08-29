class Order < ActiveRecord::Base
  audited
  
  STATES = ["initialized", "preparing", "pending_agent", "querying", "billing", "pending_injection", "pending_clearing", "completed", "failed", "pending_refund", "refunded"]
  ERRORS = ["vulcain_api", "vulcain", "shopelia", "billing", "user", "merchant", "limonetik", "mangopay"]

  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  belongs_to :merchant_account
  belongs_to :payment_card
  belongs_to :developer
  has_many :order_items, :dependent => :destroy
  
  validates :user, :presence => true
  validates :state_name, :presence => true, :inclusion => { :in => STATES }
  validates :uuid, :presence => true, :uniqueness => true
  validates :address, :presence => true
  validates :expected_price_total, :presence => true
  validates :developer, :presence => true

  attr_accessible :user_id, :address_id, :merchant_account_id, :payment_card_id, :developer_id
  attr_accessible :message, :products, :shipping_info, :should_auto_cancel, :confirmation
  attr_accessible :expected_price_product, :expected_price_shipping, :expected_price_total
  attr_accessible :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attr_accessible :mangopay_contribution_id, :mangopay_contribution_amount, :mangopay_contribution_status
  attr_accessible :mangopay_contribution_message, :mangopay_amazon_voucher_id, :mangopay_amazon_voucher_code
  attr_accessible :billing_solution, :injection_solution, :cvd_solution, :tracker
  attr_accessor :products, :confirmation
  
  scope :delayed, lambda { where("state_name='pending_agent' and created_at < ?", Time.zone.now - 3.minutes ) }
  scope :expired, lambda { where("state_name='pending_agent' and created_at < ?", Time.zone.now - 12.hours ) }
  scope :canceled, lambda { where("state_name='querying' and updated_at < ?", Time.zone.now - 2.hours ) }
  scope :preparing_stale, lambda { where("state_name='preparing' and updated_at < ?", Time.zone.now - 5.minutes ) }
  
  scope :preparing, lambda { where("state_name='preparing'") }
  scope :pending_agent, lambda { where("state_name='pending_agent'") }
  scope :pending_clearing, lambda { where("state_name='pending_clearing'") }
  scope :pending_refund, lambda { where("state_name='pending_refund'") }
  scope :querying, lambda { where("state_name='querying'") }
  scope :completed, lambda { where("state_name='completed'") }
  scope :failed, lambda { where("state_name='failed'") }
  scope :running, lambda { where("state_name<>'completed' and state_name<>'failed'") }
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :initialize_merchant_account
  before_validation :verify_prices_integrity
  before_save :serialize_questions
  before_create :validates_products
  after_initialize :deserialize_questions
  after_create :prepare_order_items
  after_create :mirror_solutions_from_merchant, :if => Proc.new { |order| !order.destroyed? }
  after_create :start, :if => Proc.new { |order| !order.destroyed? }
  after_create :notify_creation_to_admin, :if => Proc.new { |order| !order.destroyed? }
  
  def to_param
    self.uuid
  end
  
  def start
    return unless [:initialized, :pending_agent, :querying].include?(self.state) && self.payment_card_id.present? && self.order_items.count > 0
    if self.merchant.vendor.nil?
      fail("unsupported", "vulcain")
      self.save
      return
    end
    @questions = []
    self.error_code = nil
    self.message = nil
    self.state = :preparing
    self.save
    assess Vulcain::Order.create(Vulcain::OrderSerializer.new(self).as_json[:order])
    Leftronic.new.notify_order(self)
    true
  end

  def restart
    return unless [:preparing].include?(state)
    if self.retry_count.to_i < Rails.configuration.max_retry
      self.merchant_account_id = MerchantAccount.create(user_id:self.user_id, merchant_id:self.merchant_id, address_id:self.address_id).id
      self.retry_count = self.retry_count.to_i + 1
      self.state = :initialized
      start
    else
      fail("account_creation_failed", :merchant)
      self.save
    end
  end

  def callback verb, content
    return unless [:preparing].include?(state)
    
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
      when "no_product_available" then abort("stock", :merchant)
      when "out_of_stock" then abort("stock", :merchant)
      when "no_delivery" then abort("delivery", :merchant)
      when "order_validation_failed" then abort("payment_refused_by_merchant", :billing)
      when "account_creation_failed" then restart
      when "login_failed" then restart
      end

    elsif verb.eql?("assess")
      @questions = content["questions"]
      
      (content["products"] || []).each do |product|
        if product["id"].nil?
          product["id"] = Product.find_by_url(Linker.clean(product["url"])).product_versions.first.id
        end
        item = self.order_items.where(:product_version_id => product["id"]).first
        item.update_attribute(:price, product["price"] || product["price_product"] || product["product_price"])
      end

      prepared_price_product = content["billing"]["total"].to_f - content["billing"]["shipping"].to_f

      # Set product price if unique item and without price
      if self.order_items.count == 1 && self.order_items.first.price.to_i == 0
        self.order_items.first.update_attribute :price, prepared_price_product
      end

      self.prepared_price_total = content["billing"]["total"].to_f
      self.prepared_price_shipping = content["billing"]["shipping"].to_f
      self.prepared_price_product = prepared_price_product
      self.save!
      
      if self.expected_price_total >= self.prepared_price_total
      
        # Basic user payment
        if self.billing_solution.nil?
          callback_vulcain(true)
          
        # MangoPay billing
        elsif self.billing_solution == "mangopay"
          self.state = :billing
          billing_result = MangoPayFunnel.bill(self)
          if billing_result["Status"] == "success"
          
            # Billing success
            if self.reload.mangopay_contribution_status == "success"              
            
              # Limonetik CVD & injection
              if self.cvd_solution == "limonetik" && self.injection_solution == "limonetik"
                callback_vulcain(true)
                self.state = :pending_injection
                
              # Amazon vouchers
              elsif self.cvd_solution == "amazon" && self.injection_solution == "vulcain"
                self.state = :preparing
                
                voucher_result = MangoPayFunnel.voucher(self)
                if voucher_result["Status"] == "success"
                  callback_vulcain(true)
                else
                  callback_vulcain(false)
                  fail(voucher_result["Error"], :shopelia)
                end
                
              # Invalid CVD solution
              else
                callback_vulcain(false)
                fail("invalid_cvd_solution", :shopelia)
              end
              
            # Billing failure
            else
              callback_vulcain(false)
              abort(self.mangopay_contribution_message, :billing)
            end
            
          else
            callback_vulcain(false)
            fail(billing_result["Error"], :shopelia)
          end
          
        # Invalid billing solution
        else
          callback_vulcain(false)
          fail("invalid_billing_solution", :shopelia)      
        end
      else
        callback_vulcain(false)
        query
      end
      
    elsif verb.eql?("success")
      self.billed_price_total = content["billing"]["total"]
      self.billed_price_shipping = content["billing"]["shipping"]
      self.billed_price_product = self.billed_price_total - self.billed_price_shipping
      self.shipping_info = content["billing"]["shipping_info"]
      complete
      
    end

    self.save!
    
    rescue Exception => e
      callback_vulcain(false) if verb.eql?("assess")
      fail("Error during order Callback\n#{e.inspect}", :shopelia)
      self.update_attribute :prepared_price_product, 0 # allow save if price mismatch
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
  
  def shopelia_time_out
    abort "timed_out", :shopelia
    self.save!
  end

  def vulcain_time_out
    return unless [:preparing].include?(state)
    fail "preparing_stale", :vulcain
    self.save!
  end

  def cancel
    abort "canceled", :shopelia
    self.save!
  end
  
  def reject reason
    abort reason, :user
    self.save!
  end
  
  def accept
    return unless [:querying].include?(state)
    self.expected_price_total = self.prepared_price_total
    self.expected_price_shipping = self.prepared_price_shipping
    self.expected_price_product = self.prepared_price_product
    self.prepared_price_total = nil
    self.prepared_price_product = nil
    self.prepared_price_shipping = nil
    start
  end
  
  def complete
    return if state == :failed
    self.error_code = nil
    self.message = nil
    self.state = :completed
    Leftronic.new.notify_order(self)
    Emailer.notify_order_success(self).deliver
  end

  def injection_success
    return unless [:pending_injection].include?(state)
    self.state = :pending_clearing
    save
  end
  
  def clearing_success
    return unless [:pending_clearing].include?(state)
    complete
    save
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
    return unless [:preparing].include?(state)
    self.state = :querying
    Leftronic.new.notify_order(self)
    Emailer.notify_order_price_change(self).deliver
  end

  def fail content, error_sym
    return unless [:initialized, :preparing, :billing, :pending_injection].include?(state)
    self.message = content
    self.error_code = check_error_validity(error_sym.to_s)
    self.state = :pending_agent
    Leftronic.new.notify_order(self)
    Emailer.notify_admin_order_failure(self).deliver
  end

  def abort content, error_sym
    return unless [:initialized, :preparing, :pending_agent, :billing, :querying, :pending_agent, :pending_clearing].include?(state)
    self.message = content
    self.error_code = check_error_validity(error_sym.to_s) unless error_sym.nil?
    self.state = :failed
    Leftronic.new.notify_order(self)
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
  
  def initialize_merchant_account
    self.merchant_account_id = MerchantAccount.find_or_create_for_order(self).id if self.merchant_account_id.nil?
  end
  
  def mirror_solutions_from_merchant
    self.billing_solution = self.merchant.billing_solution if self.billing_solution.nil?
    self.injection_solution = self.merchant.injection_solution if self.injection_solution.nil?
    self.cvd_solution = self.merchant.cvd_solution if self.cvd_solution.nil?
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
          
        self.errors.add(:base, I18n.t('orders.errors.duplicate_order')) if OrderItem.where(order_id:self.user.orders.where("created_at >= ?", 5.minutes.ago).map(&:id)).where(product_version_id: ProductVersion.where(product_id:product.id).map(&:id)).count > 0

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
      p[:quantity] ||= 1
      if product.nil? || !product.persisted? || self.merchant_id && self.merchant_id != product.merchant_id
        self.destroy and return
      end
      self.merchant_id = product.merchant_id
      self.save
      order = OrderItem.create!(order:self, product_version:product.product_versions.first, price:p[:price].to_i*p[:quantity], quantity:p[:quantity])
    end
    if self.order_items.count == 1 && self.order_items.first.price.to_i == 0
      item = self.order_items.first
      item.update_attribute :price, self.expected_price_product / item.quantity
    end
  end
  
  def verify_prices_integrity
    if self.prepared_price_product.to_i > 0 && self.prepared_price_product.round(2) != self.order_items.map(&:price).sum.round(2)
      self.errors.add(:base, I18n.t('orders.errors.price_inconsistency'))
    elsif self.expected_price_total.to_i > 0 && self.expected_price_product.to_i == 0
      self.expected_price_product = self.expected_price_total
      self.expected_price_shipping = 0
    elsif self.expected_price_total.to_i == 0
      self.expected_price_total = self.expected_price_product.to_i + self.expected_price_shipping.to_i
    elsif self.expected_price_total.round(2) != (self.expected_price_product + self.expected_price_shipping).round(2)
      self.errors.add(:base, I18n.t('orders.errors.price_inconsistency'))
    end
  end
  
  def serialize_questions
    self.questions_json = (@questions || []).to_json
  end
  
  def deserialize_questions
    @questions = JSON.parse(self.questions_json || "[]")
  end
  
  def callback_vulcain confirmed
    return if @questions.empty?
    begin
      self.message = "vulcain_assessment_done"
      @questions.each { |question| question["answer"] = confirmed }
      assess Vulcain::Answer.create(Vulcain::ContextSerializer.new(self).as_json)
    rescue Exception => e
      fail("Error parsing callback data\n#{e.inspect}", :vulcain_api)    
    end
  end

  def notify_creation_to_admin
    Emailer.notify_admin_order_creation(self).deliver
  end
  
end
