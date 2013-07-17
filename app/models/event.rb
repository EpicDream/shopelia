class Event < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  belongs_to :developer
  
  VIEW = 0
  CLICK = 1
  
  validates :product, :presence => true
  validates :developer, :presence => true
  validates :action, :presence => true, :inclusion => { :in => [ VIEW, CLICK ] }

  before_validation :find_or_create_product

  attr_accessor :url
  
  private
  
  def find_or_create_product
    self.product = Product.fetch(self.url) unless self.url.blank?
  end
  
end
