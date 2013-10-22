class AddMultipleAddressesToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :multiple_addresses, :boolean, :default => false
  end
end
