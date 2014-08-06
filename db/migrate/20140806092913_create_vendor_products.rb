class CreateVendorProducts < ActiveRecord::Migration
  def change
    create_table :vendor_products, :force => true do |t|
      t.string :url
      t.string :image_url
      t.string :vendor
      t.boolean :similar, default: false
      t.integer :product_id #this is not foreign key, its an identifier for merchant product
      t.references :look_product
      t.timestamps
    end
    add_index :vendor_products, :look_product_id
  end
end