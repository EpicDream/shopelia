class Order < ActiveRecord::Base
  audited
  
  STATES = ["initialized", "preparing", "pending_agent", "querying", "billing", "pending_injection", "pending_clearing", "completed", "failed", "pending_refund", "refunded", "queued"]
  ERRORS = ["vulcain_api", "vulcain", "shopelia", "billing", "user", "merchant", "limonetik", "mangopay"]

  belongs_to :meta_order
  belongs_to :user
  belongs_to :merchant
  belongs_to :merchant_account
  belongs_to :developer
  has_many :order_items, :dependent => :destroy
  has_one :payment_transaction
  
  validates :user, :presence => true
  validates :state_name, :presence => true, :inclusion => { :in => STATES }
  validates :uuid, :presence => true, :uniqueness => true
  validates :expected_price_total, :presence => true
  validates :developer, :presence => true
  validates :meta_order, :presence => true

  attr_accessible :user_id, :address_id, :merchant_account_id, :payment_card_id, :developer_id
  attr_accessible :message, :products, :shipping_info, :should_auto_cancel, :confirmation
  attr_accessible :expected_price_product, :expected_price_shipping, :expected_price_total
  attr_accessible :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attr_accessible :injection_solution, :cvd_solution, :tracker, :meta_order_id, :expected_cashfront_value
  attr_accessible :gift_message, :uuid, :state_name, :informations
  attr_accessor :products, :confirmation, :payment_card_id, :address_id
  
  scope :delayed, lambda { where("state_name='pending_agent' and created_at < ?", Time.zone.now - 3.minutes ) }
  scope :expired, lambda { where("state_name='pending_agent' and created_at < ?", Time.zone.now - 18.hours ) }
  scope :canceled, lambda { where("state_name='querying' and updated_at < ?", Time.zone.now - 12.hours ) }
  scope :preparing_stale, lambda { where("state_name='preparing' and updated_at < ?", Time.zone.now - 5.minutes ) }
  
  scope :preparing, lambda { where("state_name='preparing'") }
  scope :pending_agent, lambda { where("state_name='pending_agent'") }
  scope :pending_clearing, lambda { where("state_name='pending_clearing'") }
  scope :pending_refund, lambda { where("state_name='pending_refund'") }
  scope :querying, lambda { where("state_name='querying'") }
  scope :completed, lambda { where("state_name='completed'") }
  scope :failed, lambda { where("state_name='failed'") }
  scope :running, lambda { where("state_name<>'completed' and state_name<>'failed'") }
  scope :queued, lambda { where("state_name='queued'") }
  
  before_validation :initialize_uuid
  before_validation :initialize_state
  before_validation :initialize_meta_order, :if => Proc.new { |order| order.meta_order_id.nil? }
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
  
  def start_from_queue
    return unless self.state == :queued
    self.state = :initialized
    start
  end

  def queue_busy?
    Order.where(user_id:self.user_id).where("state_name not in (?)", ["queued", "completed", "failed", "pending_agent", "refunded", "querying"]).count > 0
  end

  def start
    return unless [:initialized, :pending_agent, :querying].include?(self.state) && self.meta_order.payment_card_id.present? && self.order_items.count > 0
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
      when "cart_amount_error" then fail("cart_amount_error", :vulcain)
      when "dispatcher_crash" then fail("dispatcher_crash", :vulcain)
      when "cart_line_mapping_error" then fail("cart_line_mapping_error", :vulcain)
      when "gift_message_failure" then fail("gift_message_failure", :vulcain)
      when "address_error" then fail("address_error", :merchant)
      when "no_product_available" then abort("stock", :merchant)
      when "out_of_stock" then abort("stock", :merchant)
      when "no_delivery" then abort("delivery", :merchant)
      when "order_validation_failed" then fail("order_validation_failed", :vulcain)
      when "account_creation_failed" then restart
      when "login_failed" then restart
      end

    elsif verb.eql?("assess")
      @questions = content["questions"]
      
      (content["products"] || []).each do |product|
        if product["product_version_id"].nil? &&
          if product["id"]  
            product["product_version_id"] = Product.find(product["id"]).product_versions.first.id
          else
            product["product_version_id"] = Product.find_by_url(Linker.clean(product["url"])).product_versions.first.id
          end
        end
        item = self.order_items.where(:product_version_id => product["product_version_id"]).first
        if product["quantity"] && item.quantity != product["quantity"]
          callback_vulcain(false)
          fail("invalid_quantity", :vulcain)
          self.save!
          return
        end
        p = product["price"] || product["price_product"] || product["product_price"]

        # Special case Luxemburg
        if self.meta_order.address.country.iso == "LU"
          p = (p.to_f + 0.00000001) / 1.196 * 1.15
        end

        item.update_attribute(:price, p.to_f.round(2))
      end

      prepared_price_product = content["billing"]["total"].to_f.round(2) - content["billing"]["shipping"].to_f.round(2)

      # Set product price if unique item and without price
      if self.order_items.count == 1 && self.order_items.first.price.to_i == 0
        self.order_items.first.update_attribute :price, prepared_price_product
      end

      self.prepared_price_total = content["billing"]["total"].to_f.round(2)
      self.prepared_price_shipping = content["billing"]["shipping"].to_f.round(2)
      self.prepared_price_product = prepared_price_product
      self.expected_cashfront_value = self.cashfront_value
      self.save!

      if self.expected_price_total >= self.prepared_price_total
      
        # Basic user payment
        if self.meta_order.billing_solution.blank?
          callback_vulcain(true)
          
        # MangoPay billing
        elsif self.meta_order.billing_solution == "mangopay"
          self.update_attribute :state_name, "billing"
          
          # Prepare wallet
          wallet_result = self.meta_order.create_mangopay_wallet
          if wallet_result[:status] == "created"

            if !self.meta_order.fullfilled?
              billing_transaction = BillingTransaction.create!(meta_order_id:self.meta_order.id)
              billing_result = billing_transaction.process
            end

            if self.meta_order.fullfilled? || billing_result[:status] == "processed"
            
              # Billing success
              if self.meta_order.fullfilled? || billing_transaction.success

                # Virtualis CVD
                if self.cvd_solution == "virtualis" && self.injection_solution == "vulcain"
                  self.state = :preparing
                  
                  payment_transaction = PaymentTransaction.create!(order_id:self.id) 
                  payment_result = payment_transaction.process

                  if payment_result[:status] == "created"
                    callback_vulcain(true)
                  else
                    callback_vulcain(false)
                    fail(payment_result[:message], :shopelia)
                  end
                  
                # Amazon vouchers
                elsif self.cvd_solution == "amazon" && self.injection_solution == "vulcain"
                  self.state = :preparing

                  # Cashfront
                  if self.cashfront_value > 0 && self.meta_order.billing_transactions.successfull.cashfront.count == 0
                    cashfront_transaction = BillingTransaction.create!(meta_order_id:self.meta_order.id, processor:"cashfront")
                    cashfront_result = cashfront_transaction.process

                    if cashfront_result[:status] != "processed"
                      callback_vulcain(false)
                      fail(cashfront_result[:message], :shopelia)
                      self.save!
                      return
                    end
                  end
                 
                  payment_transaction = self.payment_transaction || PaymentTransaction.create!(order_id:self.id) 
                  payment_result = payment_transaction.process

                  if payment_result[:status] == "created"
                    callback_vulcain(true)
                  else
                    callback_vulcain(false)
                    fail(payment_result[:message], :shopelia)
                  end
                  
                # Limonetik
                elsif self.cvd_solution == "limonetik" && self.injection_solution == "limonetik"
                  callback_vulcain(true)
                  self.state = :pending_injection

                # Invalid CVD solution
                else
                  callback_vulcain(false)
                  fail("invalid_cvd_solution_#{self.cvd_solution}", :shopelia)
                end
                
              # Billing failure
              else
                callback_vulcain(false)
                abort(billing_transaction.mangopay_contribution_message, :billing)
              end
              
            else
              callback_vulcain(false)
              fail(billing_result[:message], :shopelia)
            end

          else
            callback_vulcain(false)
            fail(wallet_result[:message], :shopelia)
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
      self.billed_price_total = self.prepared_price_total
      self.billed_price_shipping = self.prepared_price_shipping
      self.billed_price_product = self.prepared_price_product
      self.shipping_info = content["billing"]["shipping_info"]
      complete
      
    end

    self.save!
    
    rescue Exception => e
      callback_vulcain(false) if verb.eql?("assess")
      fail("Error in Callback #{e.inspect}", :shopelia)
      # allow save if price mismatch
      self.prepared_price_product = 0
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

  def cashfront_value
    v = 0.0
    options = { developer:self.developer, device:self.user.devices.order(:updated_at).last }
    self.order_items.each do |item|
      v += item.cashfront_value(options)
    end
    v.round(2)
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
  
  def initialize_meta_order
    meta = MetaOrder.new(
      user_id:self.user_id,
      payment_card_id:self.payment_card_id,
      address_id:self.address_id)
    if meta.save
      self.meta_order_id = meta.id
    else
      self.errors.add(:base, meta.errors.full_messages.join(","))
    end
  end

  def mirror_solutions_from_merchant
    self.meta_order.update_attribute :billing_solution, self.merchant.billing_solution if self.meta_order.billing_solution.nil?
    self.injection_solution = self.merchant.injection_solution if self.injection_solution.nil?
    self.cvd_solution = self.merchant.cvd_solution if self.cvd_solution.nil?
    self.save!
  end
  
  def validates_products  
    if self.products.nil? || self.products.count == 0
      self.errors.add(:base, I18n.t('orders.errors.no_product'))
    else
      self.products.each do |p|
        if p[:url].present?
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
    end
    self.errors.count == 0
  end
  
  def prepare_order_items
    self.products.each do |p|
      if p[:url].present?
        product = Product.fetch(p[:url])
        p[:quantity] ||= 1
        if product.nil? || !product.persisted? || self.merchant_id && self.merchant_id != product.merchant_id
          self.destroy and return
        end
        OrderItem.create!(
          order_id:self.id, 
          product_version:product.product_versions.first, 
          price:p[:price].to_f.round(2),
          quantity:p[:quantity].to_i)
      elsif p[:product_version_id].present?
        v = ProductVersion.find(p[:product_version_id].to_i)
        product = v.product
        OrderItem.create!(
          order_id:self.id, 
          product_version:v, 
          price:v.price,
          quantity:(p[:quantity] || 1).to_i)
      end
      if product.nil?
        self.destroy 
        self.errors.add(:base, I18n.t('orders.errors.invalid_product', :error => ""))
        return
      else
        self.merchant_id = product.merchant_id if self.merchant_id.nil?
        self.merchant_account_id = MerchantAccount.find_or_create_for_order(self).id if self.merchant_account_id.nil?
        self.save!
      end
    end
    if self.order_items.count == 1 && self.order_items.first.price.to_i == 0
      item = self.order_items.first
      item.update_attribute :price, self.expected_price_product / item.quantity
    end
    self.reload
  end
  
  def verify_prices_integrity
    self.expected_price_product = self.expected_price_product.to_f.round(2)
    self.expected_price_total = self.expected_price_total.to_f.round(2)
    self.expected_price_shipping = self.expected_price_shipping.to_f.round(2)
    self.expected_cashfront_value = self.expected_cashfront_value.to_f.round(2)
    if self.prepared_price_product.to_i > 0 && self.prepared_price_product.round(2) != self.order_items.map{ |e| e.price * e.quantity}.sum.round(2)
      self.errors.add(:base, I18n.t('orders.errors.price_inconsistency'))
    elsif self.expected_price_total.to_i > 0 && self.expected_price_product.to_i == 0
      self.expected_price_product = self.expected_price_total
      self.expected_price_shipping = 0
    elsif self.expected_price_total.to_i == 0
      self.expected_price_total = self.expected_price_product.to_i + self.expected_price_shipping.to_i
    elsif self.expected_price_total.round(2) != (self.expected_price_product + self.expected_price_shipping).round(2)
      self.errors.add(:base, I18n.t('orders.errors.price_inconsistency'))
    end
    if self.order_items.count > 0 && self.expected_cashfront_value != self.cashfront_value
      self.errors.add(:base, I18n.t('orders.errors.cashfront_inconsistency'))
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
