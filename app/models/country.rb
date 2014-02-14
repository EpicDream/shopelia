class Country < ActiveRecord::Base
  has_many :addresses
  has_many :states
  has_many :users
  has_many :flinkers
  
  attr_accessible :id, :name, :iso
  
end
