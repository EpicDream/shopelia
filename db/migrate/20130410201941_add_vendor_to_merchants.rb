class AddVendorToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :vendor, :string
  end
end
