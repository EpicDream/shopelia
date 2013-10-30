class AddDeviceIdToCashfrontRules < ActiveRecord::Migration
  def change
    add_column :cashfront_rules, :device_id, :integer
  end
end
