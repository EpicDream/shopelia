class PaymentTransaction < ActiveRecord::Base
  belongs_to :order
  has_one :user, :through => :order

  validates :order, :presence => true
  validates :processor, :presence => true
  
  attr_accessible :mangopay_amazon_voucher_code, :mangopay_amazon_voucher_id, :order_id, :processor, :mangopay_source_wallet_id

  before_validation :initialize_transaction

  def process
    if self.processor == "amazon"
      return { status:"error", message:"transaction already processed" } unless self.mangopay_amazon_voucher_id.nil?
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
