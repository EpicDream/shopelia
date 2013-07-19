class AddDeveloperToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :developer_id, :integer
  end
end
