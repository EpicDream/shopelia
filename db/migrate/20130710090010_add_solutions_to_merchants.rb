class AddSolutionsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :billing_solution, :string
    add_column :merchants, :injection_solution, :string
    add_column :merchants, :cvd_solution, :string
  end
end
