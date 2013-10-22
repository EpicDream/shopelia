class AddInformationsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :informations, :string
  end
end
