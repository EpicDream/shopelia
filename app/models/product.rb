class Product < ActiveRecord::Base
  belongs_to :merchant
  
  validates :name, :presence => true
  validates :url, :presence => true, :uniqueness => true
end
