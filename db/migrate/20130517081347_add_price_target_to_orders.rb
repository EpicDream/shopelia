class AddPriceTargetToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :price_target, :float
  end
end
