class AddMaxOrdersCountToCashfrontRules < ActiveRecord::Migration
  def change
    add_column :cashfront_rules, :max_orders_count, :integer
  end
end
