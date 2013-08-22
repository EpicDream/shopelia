class AddDeveloperIdToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :developer_id, :integer
  end
end
