class AddTrackerToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :tracker, :string
  end
end
