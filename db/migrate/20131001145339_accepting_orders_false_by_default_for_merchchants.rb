class AcceptingOrdersFalseByDefaultForMerchchants < ActiveRecord::Migration
  def up
    change_column :merchants, :accepting_orders, :boolean, :default => false
  end

  def down
    change_column :merchants, :accepting_orders, :boolean, :default => true
  end
end
