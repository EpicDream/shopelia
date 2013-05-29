class Country < ActiveRecord::Base
  has_many :addresses
  has_many :states
  has_many :users
  
  attr_accessible :id, :name, :iso
end
