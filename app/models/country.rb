class Country < ActiveRecord::Base
  has_many :addresses
  has_many :states
  has_many :users
end
