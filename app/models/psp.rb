class Psp < ActiveRecord::Base
  LEETCHI = "Leetchi"

  has_many :psp_users, :dependent => :destroy
  has_many :psp_payment_cards, :dependent => :destroy
  
  validates :name, :presence => :true, :uniqueness => true
  
  attr_accessible :name
end
