class AddColumnsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    add_column :products, :images, :text
    add_column :products, :options, :text
    add_column :products, :last_checked_at, :datetime
    add_column :products, :price, :float
    add_column :products, :price_shipping, :float
    add_column :products, :price_strikeout, :float
  end
end
