class MerkavTransaction < ActiveRecord::Base
  belongs_to :virtual_cards

  validates :amount, :inclusion => 100..10000

  attr_accessible :amount, :executed_at, :merkav_transaction_id, :optkey, :status, :token

  def generate_virtual_card
    card = VirtualCard.new(amount:self.amount, provider:"virtualis")
    if card.save
      self.update_attribute :virtual_card_id, card.id
      { status:"ok" }
    else
      { status:"error", error:card.errors.full_messages.join(",")}
    end
  end
end