class AddPricesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billed_price_product, :float
    add_column :orders, :billed_price_shipping, :float
  end
end
