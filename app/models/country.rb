class Country < ActiveRecord::Base
  FRANCE = :FR
  ALL_IN_USE = ['FR', 'DE', 'GB', 'IT', 'US']
  
  has_many :addresses
  has_many :states
  has_many :users
  has_many :flinkers
  
  attr_accessible :id, :name, :iso
  
  def self.in_use
    where(iso:ALL_IN_USE)
  end
  
  def self.en
    where(iso:'GB').first
  end
  
  def self.fr
    where(iso:'FR').first
  end
  
  def self.ids
    Rails.cache.fetch([:country, :ids], expires_in: 1.month) {
      Country.pluck(:id)
    }
  end
  
end
