class AddRetryCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :retry_count, :integer
  end
end
