class AddLeetchiContributionMessageToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :leetchi_contribution_message, :string
  end
end
