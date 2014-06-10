class AddStaffPickToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :staff_pick, :boolean, default:false
  end
end