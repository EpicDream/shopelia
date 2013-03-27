class Phone < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  LAND = 0
  MOBILE = 1
  
  validates :number, :presence => true, :uniqueness => true
  validates :line_type, :presence => true, :inclusion => { :in => [ LAND, MOBILE ] }
  
end
