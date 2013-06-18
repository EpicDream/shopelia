class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  has_many :psp_payment_cards, :dependent => :destroy
  
  validates :user, :presence => true
  validates :number, :presence => true, :length => { :is => 16 }
  validates :exp_month, :presence => true, :length => { :is => 2 }
  validates :exp_year, :presence => true, :length => { :is => 4 }
  validates :cvv, :presence => true, :length => { :is => 3 }
  
  after_create :create_psp_payment_cards
  before_destroy :destroy_psp_payment_cards, :if => Proc.new { |card| card.leetchi.present? }
  
  def leetchi
    self.psp_payment_cards.leetchi.first
  end
  
  def create_leetchi
    return unless self.leetchi.nil? && self.user.leetchi.present?
    wrapper = Psp::LeetchiPaymentCard.new
    wrapper.create(self)
    Emailer.leetchi_card_creation_failure(self,wrapper.errors).deliver unless self.leetchi.present?
  end
  
  private
  
  def create_psp_payment_cards
    if Rails.env.production?
      SuckerPunch::Queue[:leetchi_card_queue].async.perform(self)
    else 
      create_leetchi unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"
    end
  end
  
  def destroy_psp_payment_cards
    Psp::LeetchiPaymentCard.new.destroy(self) unless self.leetchi.nil?
    true
  end
    
end
