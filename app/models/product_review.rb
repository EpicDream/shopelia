class ProductReview < ActiveRecord::Base
  validates :author, :uniqueness => {:scope => :product_id}
  
end
