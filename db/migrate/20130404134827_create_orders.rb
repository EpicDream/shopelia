class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :merchant_id
      t.integer :product_id
      t.string :uuid
      t.string :state_name
      t.string :message
      t.float :price_product
      t.float :price_delivery
      t.float :price_total

      t.timestamps
    end
  end
end
