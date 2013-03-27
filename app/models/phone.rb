class Phone < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  LAND = 0
  MOBILE = 1
  
  validates :user, :presence => true
  validates :number, :presence => true, :uniqueness => true
  validates :line_type, :presence => true, :inclusion => { :in => [ LAND, MOBILE ] }
  
  attr_accessible :user_id, :address_id, :number, :line_type
  
end
