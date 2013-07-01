class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  
  validates :user, :presence => true
  validates :number, :presence => true, :length => { :is => 16 }
  validates :exp_month, :presence => true, :length => { :is => 2 }
  validates :exp_year, :presence => true, :length => { :is => 4 }
  validates :cvv, :presence => true, :length => { :is => 3 }
  
  before_destroy :destroy_leetchi_payment_card, :if => Proc.new { |card| card.leetchi_id.present? }
  
  private
  
  def destroy_leetchi_payment_card
    Leetchi::Card.delete(self.leetchi_id)
  end
    
end
