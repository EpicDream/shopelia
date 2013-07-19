class CreateProductVersions < ActiveRecord::Migration
  def change
    create_table :product_versions do |t|
      t.integer :product_id
      t.float :price
      t.float :price_shipping
      t.float :price_strikeout
      t.string :shipping_info
      t.text :options
      t.text :description

      t.timestamps
    end
    
    Product.all.each do |product|
      ProductVersion.create!(product_id:product.id)
    end
  end
end
