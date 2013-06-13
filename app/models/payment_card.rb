class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  has_many :psp_payment_cards, :dependent => :destroy
  
  validates :user, :presence => true
  validates :number, :presence => true, :length => { :is => 16 }
  validates :exp_month, :presence => true, :length => { :is => 2 }
  validates :exp_year, :presence => true, :length => { :is => 4 }
  validates :cvv, :presence => true, :length => { :is => 3 }
  
  before_destroy :destroy_psp_payment_cards, :if => Proc.new { |card| card.leetchi.present? }
  
  def leetchi
    self.psp_payment_cards.leetchi.first
  end
  
  def create_leetchi
    return unless self.leetchi.nil?
    wrapper = Psp::LeetchiPaymentCard.new
    wrapper.create(self)
    wrapper.errors
  end
  
  private
  
  def destroy_psp_payment_cards
    Psp::LeetchiPaymentCard.new.destroy(self)
    true
  end
    
end
