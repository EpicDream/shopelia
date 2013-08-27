class Cart < ActiveRecord::Base
  belongs_to :user
  has_many :cart_items, :dependent => :destroy

  validates :user, :presence => true

  attr_accessible :name, :user_id  
end
