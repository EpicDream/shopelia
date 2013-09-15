class VirtualCard < ActiveRecord::Base
  has_one :payment_transaction

  validates :amount, :presence => true
  validates :provider, :presence => true

  attr_accessible :amount, :provider

  before_create :generate_cvd

  private

  def generate_cvd
    if self.provider == "virtualis"
      generate_virtualis_cvd
    end
  end

  def generate_virtualis_cvd
    card = Virtualis::Card.create({montant:(self.amount * 100).to_i.to_s, duree:'12'})
    if card['status'] == 'ok'
      self.cvd_id = card['numeroReference'].to_i
      clone_card(card)
    else
      self.errors.add(:base, card['error_str'])
    end
  end

  def clone_card card
    self.number = card['number']
    self.exp_month = card['exp_month']
    self.exp_year = card['exp_year']
    self.cvv = card['cvv']
  end    
end
