class CreateDevelopersProductsTable < ActiveRecord::Migration
  def up
    create_table :developers_products, :id => false do |t|
      t.references :developer
      t.references :product
    end
    add_index :developers_products, :product_id
  end

  def down
    drop_table :developers_products
  end
end
