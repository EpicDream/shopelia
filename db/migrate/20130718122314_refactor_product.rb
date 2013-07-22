class RefactorProduct < ActiveRecord::Migration
  def change
    remove_column :products, :last_checked_at
    remove_column :products, :price
    remove_column :products, :price_shipping
    remove_column :products, :price_strikeout
    remove_column :products, :options
    add_column :products, :product_master_id, :integer
    add_column :products, :brand, :string
    add_column :products, :versions_expires_at, :datetime
  end
end
