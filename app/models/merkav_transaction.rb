class MerkavTransaction < ActiveRecord::Base
  belongs_to :virtual_card

  validates :amount, :inclusion => 100..10000
  validates :vad_id, :presence => true

  before_create :check_quota

  attr_accessible :amount, :vad_id

  def generate_virtual_card
    return { status:"ok" } if self.virtual_card.present?
    card = VirtualCard.new(amount:self.amount, provider:"virtualis")
    if card.save
      self.update_attribute :virtual_card_id, card.id
      { status:"ok" }
    else
      { status:"error", error:card.errors.full_messages.join(",")}
    end
  end

  private

  def check_quota
    quota = Customers::Merkav.get_quota
    total = MerkavTransaction.where(status:'success').sum(:amount) + self.amount
    self.errors.add(:base, "Quota exceded, please contact administrator") and return false if total > quota
  end
end