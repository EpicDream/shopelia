class AddIndexProductIdAuthorToProductReviews < ActiveRecord::Migration
  def change
    add_index :product_reviews, [:product_id, :author]
  end
end