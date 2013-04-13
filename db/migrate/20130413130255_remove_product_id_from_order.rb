class RemoveProductIdFromOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :product_id
  end

  def down
    remove_column :orders, :product_id, :integer
  end
end
