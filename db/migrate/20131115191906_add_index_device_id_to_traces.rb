class AddIndexDeviceIdToTraces < ActiveRecord::Migration
  def change
    add_index :traces, :device_id
  end
end
