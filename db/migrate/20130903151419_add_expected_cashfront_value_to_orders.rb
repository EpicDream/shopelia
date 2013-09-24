class AddExpectedCashfrontValueToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :expected_cashfront_value, :float
  end
end
