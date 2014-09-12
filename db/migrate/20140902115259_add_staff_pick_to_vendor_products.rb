class AddStaffPickToVendorProducts < ActiveRecord::Migration
  def change
    add_column :vendor_products, :staff_pick, :boolean, default: false
  end
end