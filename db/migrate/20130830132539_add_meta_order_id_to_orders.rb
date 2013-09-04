class AddMetaOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :meta_order_id, :integer
  end
end
