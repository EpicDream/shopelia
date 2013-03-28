class Psp < ActiveRecord::Base
  has_many :psp_users, :dependent => :destroy
  
  validates :name, :presence => :true, :uniqueness => true
  
  attr_accessible :name
end
