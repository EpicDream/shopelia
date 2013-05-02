class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :psp_payment_cards
  
  validates :user, :presence => true
  validates :number, :presence => true, :length => { :is => 16 }
  validates :exp_month, :presence => true, :length => { :is => 2 }
  validates :exp_year, :presence => true, :length => { :is => 4 }
  validates :cvv, :presence => true, :length => { :is => 3 }
  
  after_save :create_psp_payment_cards
  before_destroy :destroy_psp_payment_cards
  
  def leetchi
    self.psp_payment_cards.leetchi.first
  end
  
  private
  
  def create_psp_payment_cards
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"
      if self.leetchi.nil?
        wrapper = Psp::LeetchiPaymentCard.new
        if !wrapper.create(self)
          self.destroy
          self.errors.add(:base, I18n.t('leetchi.payment_cards.creation_failure', :error => wrapper.errors))
          false
        end
      end
    end
  end
  
  def destroy_psp_payment_cards
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"
      if self.leetchi.present?
        wrapper = Psp::LeetchiPaymentCard.new
        if !wrapper.destroy(self)
          self.errors.add(:base, I18n.t('leetchi.payment_cards.destroy_failure', :error => wrapper.errors))
          false
        else
          self.leetchi.destroy
        end
      end
    end
  end
    
end
