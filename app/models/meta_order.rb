class MetaOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :address
  belongs_to :payment_card
  has_many :orders, :dependent => :destroy
  has_many :billing_transactions

  validates :user, :presence => true
  validates :address, :presence => true
  validates :payment_card, :presence => true

  attr_accessible :user_id, :address_id, :payment_card_id, :billing_solution, :mangopay_wallet_id

  def billed_amount
    self.billing_transactions.active.map(&:amount).sum
  end

  def create_mangopay_wallet
    return { status:"error", message:"billing solution must be mangopay" } unless self.billing_solution == "mangopay"
    return { status:"error", message:"wallet already exists" } unless self.mangopay_wallet_id.nil?

    if self.user.mangopay_id.nil?
      result = self.user.create_mangopay_user
      return result if result[:status] == "error"
    end
    
    # Create a wallet and attach it to order
    if self.mangopay_wallet_id.nil?
      wallet = MangoPay::Wallet.create({
        'Tag' => self.id.to_s,
        'Owners' => [self.user.mangopay_id]
      })
      if wallet["ID"].present?
        self.update_attribute :mangopay_wallet_id, wallet["ID"].to_i
      else
        return { status:"error", message:"Impossible to create mangopay wallet object: #{wallet.inspect}" }
      end
    end
    
    self.reload
    { status:"created" }
  end
end
