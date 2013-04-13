class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :quantity, :default => 1
      t.float :price_unit, :default => 0
      t.string :product_title
      t.string :product_image_url
      t.string :price_text
      t.string :delivery_text

      t.timestamps
    end
  end
end
