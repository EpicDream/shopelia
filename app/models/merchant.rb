class Merchant < ActiveRecord::Base
  has_many :products, :dependent => :destroy
  has_many :orders

  validates :name, :presence => true, :uniqueness => true
  validates :vendor, :presence => true, :uniqueness => true
  validates :url, :presence => true, :uniqueness => true
end
