class BillingTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :meta_order

  validates :meta_order, :presence => true
  validates :amount, :inclusion => 0..40000
  validates :processor, :inclusion => [ "mangopay", "cashfront" ]

  attr_accessible :amount, :mangopay_contribution_amount, :mangopay_contribution_id, :mangopay_contribution_message
  attr_accessible :meta_order_id, :processor, :user_id, :success, :mangopay_destination_wallet_id

  before_validation :initialize_transaction

  scope :active, where(success:[true,nil])
  scope :successfull, where(success:true)
  scope :failed, where(success:false)

  def process
    if self.processor == "mangopay"
      return { status:"error", message:"transaction already processed" } unless self.mangopay_contribution_id.nil?
      return { status:"error", message:"missing payment card" } if self.meta_order.payment_card.nil?

      if self.meta_order.mangopay_wallet_id.nil?
        result = self.meta_order.create_mangopay_wallet 
        return result if result[:status] == "error"
      end

      if self.meta_order.payment_card.mangopay_id.nil?
        result = self.meta_order.payment_card.create_mangopay_card 
        return result if result[:status] == "error"
      end

      contribution = MangoPay::ImmediateContribution.create({
        'Tag' => self.id.to_s,
        'UserID' => self.user.mangopay_id,
        'WalletID' => self.meta_order.mangopay_wallet_id,
        'PaymentCardID' => self.meta_order.payment_card.mangopay_id,
        'Amount' => self.amount
      })
      if contribution['ID'].present?
        self.update_attributes(
          :mangopay_contribution_id => contribution['ID'],
          :mangopay_contribution_amount => contribution['Amount'],
          :mangopay_contribution_message => contribution['AnswerMessage'],
          :mangopay_destination_wallet_id => self.meta_order.mangopay_wallet_id,
          :success => contribution['IsSucceeded']
        )
      elsif contribution['Type'] == "PaymentSystem"
        self.update_attributes(
          :success => false,
          :mangopay_contribution_message => "#{contribution['UserMessage']} #{contribution['TechnicalMessage']}"
        )
      else
        return { status:"error", message:"Impossible to create mangopay immediate contribution object: #{contribution}" }
      end   

      self.reload
      { status:"processed" }

    else
      { status:"error", message:"Invalid processor : #{self.processor}" }
    end
  end

  private

  def prepare_cashfront_amount
    v = 0.0
    self.meta_order.orders.each do |order|
      options = { developer:order.developer }
      order.order_items.each do |item|
        v += item.product_version.cashfront_value(options)
      end
    end
    (v * 100).round
  end

  def prepare_billing_amount
    (orders_prepared_total - self.meta_order.billed_amount).round
  end

  def orders_expected_total
    (self.meta_order.orders.map(&:expected_price_total).sum * 100).round
  end

  def orders_prepared_total
    (self.meta_order.orders.map(&:prepared_price_total).sum * 100).round
  end

  def initialize_transaction
    self.processor = self.meta_order.billing_solution if self.processor.nil?
    self.user_id = self.meta_order.user_id if self.user_id.nil?
    if self.amount.nil?
      if self.processor == "mangopay"
        self.amount = prepare_billing_amount
      elsif self.processor == "cashfront"
        self.amount = prepare_cashfront_amount
      end
    end
    self.errors.add(:base, I18n.t('billing_transactions.errors.invalid_state')) if self.meta_order.orders.map(&:state_name).uniq != [ "billing"]
    self.errors.add(:base, I18n.t('billing_transactions.errors.price_inconsistency')) if orders_expected_total < orders_prepared_total
    self.errors.add(:base, I18n.t('billing_transactions.errors.already_fulfilled')) if !self.persisted? && self.amount + self.meta_order.billed_amount > orders_prepared_total
  end
end