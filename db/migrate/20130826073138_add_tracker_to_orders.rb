class AddTrackerToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tracker, :string
  end
end
