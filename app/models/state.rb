class State < ActiveRecord::Base
  has_many :addresses
  belongs_to :country
end
