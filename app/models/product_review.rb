class ProductReview < ActiveRecord::Base
  validates :author, presence:true
  validates :author, uniqueness: { scope: :product_id }
end
