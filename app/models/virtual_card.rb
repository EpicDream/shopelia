class VirtualCard < ActiveRecord::Base
  has_one :payment_transaction

  validates :amount, presence: true
  validates :provider, presence: true
  validate  :validate_number
  validates :exp_month, numericality: { only_integer: true,  greater_than: 0, less_than: 13 }, length: { is:2 }
  validates :exp_year, numericality: { only_integer: true, greater_than_or_equal_to: Time.now.year, less_than_or_equal_to: Time.now.year + 10 }, length: { is:4 }
  validates :cvv, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 999  }, length: { is:3 }

  attr_accessible :amount, :provider

  before_validation :generate_cvd

  private

  def validate_number
    errors.add(:number, "is invalid") unless CreditCardValidator::Validator.valid?(self.number || '')
  end

  def generate_cvd
    if self.provider == "virtualis"
      generate_virtualis_cvd
    end
  end

  def generate_virtualis_cvd
    card = Virtualis::Card.create({montant:(self.amount * 100).to_i.to_s, duree:'12'})
    if card['status'] == 'ok'
      self.cvd_id = card['numeroReference']
      clone_card(card)
    else
      self.errors.add(:base, card['error_str'])
      false
    end
  end

  def clone_card card
    self.number = card['number']
    self.exp_month = card['exp_month']
    self.exp_year = card['exp_year']
    self.cvv = card['cvv']
  end    
end
