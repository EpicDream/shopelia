class MerkavTransaction < ActiveRecord::Base
  belongs_to :virtual_cards

  validates :amount, :inclusion => 100..10000
  validates :vad_id, :presence => true

  attr_accessible :amount, :vad_id

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