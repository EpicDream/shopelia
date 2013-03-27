class Country < ActiveRecord::Base
  has_many :addresses
  has_many :states
end
