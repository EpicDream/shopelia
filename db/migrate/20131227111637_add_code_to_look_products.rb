class AddCodeToLookProducts < ActiveRecord::Migration
  def change
    add_column :look_products, :code, :string
    add_column :look_products, :brand, :string
  end
end
