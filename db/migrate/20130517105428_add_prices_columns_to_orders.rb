class AddPricesColumnsToOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :price_product
    remove_column :orders, :price_delivery
    remove_column :orders, :price_total
    remove_column :orders, :price_target
    add_column :orders, :expected_price_product, :float
    add_column :orders, :expected_price_shipping, :float
    add_column :orders, :expected_price_total, :float
    add_column :orders, :prepared_price_product, :float
    add_column :orders, :prepared_price_shipping, :float
    add_column :orders, :prepared_price_total, :float
    add_column :orders, :billed_price_total, :float
    add_column :orders, :shipping_info, :string
  end
end
