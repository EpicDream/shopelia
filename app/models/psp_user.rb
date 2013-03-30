class PspUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :psp
  
  validates :psp, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :psp_id }
  validates :remote_user_id, :presence => true, :uniqueness => { :scope => :psp_id }
  
  scope :leetchi, joins(:psp).where("psps.name=?", Psp::LEETCHI)
  
  attr_accessible :user_id, :psp_id, :remote_user_id
end
