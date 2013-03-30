class PspPaymentCard < ActiveRecord::Base
  belongs_to :payment_card
  belongs_to :psp
  
  validates :psp, :presence => true
  validates :payment_card_id, :presence => true, :uniqueness => { :scope => :psp_id }
  validates :remote_payment_card_id, :presence => true, :uniqueness => { :scope => :psp_id }
  
  scope :leetchi, joins(:psp).where("psps.name=?", Psp::LEETCHI)
  
  attr_accessible :payment_card_id, :psp_id, :remote_payment_card_id
end
