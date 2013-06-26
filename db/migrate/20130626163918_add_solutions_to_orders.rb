class AddSolutionsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billing_solution, :string
    add_column :orders, :injection_solution, :string
    add_column :orders, :cvd_solution, :string
  end
end
