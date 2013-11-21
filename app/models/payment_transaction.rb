class PaymentTransaction < ActiveRecord::Base
  belongs_to :order
  belongs_to :virtual_card
  has_one :user, :through => :order

  validates :order, :presence => true
  validates :processor, :presence => true
  
  attr_accessible :mangopay_amazon_voucher_code, :mangopay_amazon_voucher_id, :order_id, :processor, :mangopay_source_wallet_id

  before_validation :initialize_transaction

  scope :amazon, where(processor:"amazon")

  def process
    return { status:"error", message:"missing user mangopay object" } if self.user.mangopay_id.nil?
    return { status:"error", message:"missing source mangopay wallet" } if self.mangopay_source_wallet_id.nil?

    wallet = MangoPay::Wallet.details(self.mangopay_source_wallet_id)
    return { status:"error", message:"Wallet doesn't have enough money. Has #{wallet['Amount']} but need #{self.amount}" } if wallet['Amount'] < self.amount

    if self.processor == "amazon"
      return { status:"created" } unless self.mangopay_amazon_voucher_id.nil?
      return { status:"error", message:"missing user mangopay object" } if self.user.mangopay_id.nil?
      return { status:"error", message:"missing source mangopay wallet" } if self.mangopay_source_wallet_id.nil?

      wallet = MangoPay::Wallet.details(self.mangopay_source_wallet_id)
      return { status:"error", message:"Wallet doesn't have enough money. Has #{wallet['Amount']} but need #{self.amount}" } if wallet['Amount'] < self.amount

      voucher = MangoPay::AmazonVoucher.create({
        'Tag' => self.id.to_s,
        'UserID' => self.user.mangopay_id,
        'WalletID' => self.mangopay_source_wallet_id,
        'Amount' => self.amount,
        'Store' => 'FR'
      })
      if voucher['ID'].present?
        self.update_attributes(
          :mangopay_amazon_voucher_id => voucher['ID'],
          :mangopay_amazon_voucher_code => voucher['VoucherCode']
        )
        { status:"created" }
      else
        { status:"error", message:"Impossible to create amazon voucher : #{voucher.inspect}" }
      end

    elsif self.processor == "virtualis"
      return { status:"error", message:"transaction already processed" } unless self.virtual_card_id.nil?

      card = VirtualCard.new(
        amount: (self.amount.to_f / 100).round(2),
        provider: "virtualis")
      if card.save
        self.update_attribute :virtual_card_id, card.id
        { status: "created" }
      else
        { status:"error", message:"Impossible to create virtualis card : #{card.errors.full_messages.join(",")}" }
      end

    else
      { status:"error", message:"Invalid processor : #{self.processor}" }
    end
  end

  private

  def initialize_transaction
    self.processor = self.order.cvd_solution if self.processor.nil?
    self.amount = (self.order.prepared_price_total * 100).round if self.amount.nil?
    self.mangopay_source_wallet_id = self.order.meta_order.mangopay_wallet_id if self.mangopay_source_wallet_id.nil?
  end
end
