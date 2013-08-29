class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.string :uuid
      t.integer :cart_id
      t.integer :product_version_id
      t.float :price_shipping
      t.float :price
      t.boolean :monitor, :default => true

      t.timestamps
    end
  end
end
