class AddAcceptingOrdersToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :accepting_orders, :boolean, :default => true
  end
end
