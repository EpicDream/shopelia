class CreateLookProducts < ActiveRecord::Migration
  def change
    create_table :look_products do |t|
      t.integer :look_id
      t.integer :product_id

      t.timestamps
    end
  end
end
