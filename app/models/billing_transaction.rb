class BillingTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :meta_order

  validates :meta_order, :presence => true
  validates :amount, :inclusion => 1..40000
  validates :processor, :inclusion => [ "mangopay", "cashfront" ]

  attr_accessible :amount, :mangopay_contribution_amount, :mangopay_contribution_id, :mangopay_contribution_message
  attr_accessible :meta_order_id, :processor, :user_id, :success, :mangopay_destination_wallet_id, :mangopay_transfer_id

  before_validation :initialize_transaction

  scope :active, where(success:[true,nil])
  scope :successfull, where(success:true)
  scope :failed, where(success:false)
  scope :cashfront, where(processor:"cashfront")
  scope :mangopay, where(processor:"mangopay")

  def process
    if self.processor == "mangopay"
      return { status:"processed" } unless self.mangopay_contribution_id.nil?
      return { status:"error", message:"missing payment card" } if self.meta_order.payment_card.nil?
      return { status:"error", message:"missing meta order wallet" } if self.meta_order.mangopay_wallet_id.nil?

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
          :mangopay_contribution_message => "Billing failed: #{contribution.inspect}"
        )
      else
        return { status:"error", message:"Impossible to create mangopay immediate contribution object: #{contribution.inspect}" }
      end   

      self.reload
      { status:"processed" }

    elsif self.processor == "cashfront"
      return { status:"processed" } unless self.mangopay_transfer_id.nil?
      return { status:"error", message:"missing meta order wallet" } if self.meta_order.mangopay_wallet_id.nil?

      master_id = MangoPayDriver.get_master_account_id
      return { status:"error", message:"missing master cashfront account" } if master_id.nil?

      user = MangoPay::User.details(master_id)
      return { status:"error", message:"not enough money on cashfront account (required #{self.amount}, has #{user['PersonalWalletAmount']}" } if user['PersonalWalletAmount'] < self.amount

      transfert = MangoPay::Transfer.create({
        'Tag' => self.id.to_s,
        'PayerID' => master_id,
        'BeneficiaryWalletID' => self.meta_order.mangopay_wallet_id,
        'Amount' => self.amount
      })
      if transfert['ID'].present?
        self.update_attributes(
          :mangopay_transfer_id => transfert['ID'],
          :mangopay_destination_wallet_id => self.meta_order.mangopay_wallet_id,
          :success => true
        )
      else
        self.update_attributes(:success => false)
        return { status:"error", message:"Impossible to transfer cashfront value to order wallet : #{transfert}" }
      end   

      self.reload
      { status:"processed" }

    else
      { status:"error", message:"Invalid processor : #{self.processor}" }
    end
  end

  private

  def cashfront_value
    (self.meta_order.cashfront_value * 100).round
  end

  def prepare_billing_amount
    (orders_prepared_total - self.meta_order.billed_amount * 100 - cashfront_value).round
  end

  def orders_expected_total
    (self.meta_order.orders.map(&:expected_price_total).sum * 100).round
  end

  def orders_prepared_total
    (self.meta_order.prepared_price_total * 100).round
  end

  def initialize_transaction
    self.processor = self.meta_order.billing_solution if self.processor.nil?
    self.user_id = self.meta_order.user_id if self.user_id.nil?
    if self.amount.nil?
      if self.processor == "mangopay"
        self.amount = prepare_billing_amount
      elsif self.processor == "cashfront"
        self.errors.add(:base, I18n.t('billing_transactions.errors.cashfront_already_exists')) unless self.meta_order.billing_transactions.cashfront.successfull.empty?
        self.amount = cashfront_value
      end
    end
    self.errors.add(:base, I18n.t('billing_transactions.errors.invalid_state')) if self.meta_order.orders.map(&:state_name).uniq != [ "billing"]
    self.errors.add(:base, I18n.t('billing_transactions.errors.price_inconsistency')) if orders_expected_total < orders_prepared_total - cashfront_value
    self.errors.add(:base, I18n.t('billing_transactions.errors.already_fulfilled')) if !self.persisted? && self.meta_order.fullfilled? && self.processor != "cashfront"
  end
end