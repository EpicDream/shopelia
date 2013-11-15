class ProductReview < ActiveRecord::Base
  belongs_to :product
  
  validates :author, presence:true
  validates :author, uniqueness: { scope: :product_id }
end
