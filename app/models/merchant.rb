class Merchant < ActiveRecord::Base
  has_many :products, :dependent => :destroy

  validates :name, :presence => true
  validates :url, :presence => true, :uniqueness => true
end
