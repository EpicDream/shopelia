class CreateProductReviews < ActiveRecord::Migration
  def change
    create_table :product_reviews do |t|
      t.references :product
      t.integer :rating
      t.string :author
      t.text :content
      t.date :published_at
      t.timestamps
    end
  end
end