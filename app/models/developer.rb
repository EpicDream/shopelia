class Developer < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :api_key, :presence => true, :uniqueness => true, :length => { :is => 64 }
  
  attr_accessible :name, :api_key
  
  before_validation do |record|
    record.api_key = SecureRandom.hex(32) unless record.api_key?
  end
end
