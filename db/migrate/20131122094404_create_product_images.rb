class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.text :url
      t.integer :product_version_id
      t.string :size

      t.timestamps
    end

    add_index :product_images, :product_version_id
  end
end
