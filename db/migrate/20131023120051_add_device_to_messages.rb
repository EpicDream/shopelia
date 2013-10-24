class AddDeviceToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :device_id, :integer
  end
end
