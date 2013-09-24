class AddAllowQuantitiesToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :allow_quantities, :boolean, :default => true
  end
end
