class State < ActiveRecord::Base
  has_many :addresses
  belongs_to :country
  
  attr_accessible :id, :iso, :name, :country_id
end
