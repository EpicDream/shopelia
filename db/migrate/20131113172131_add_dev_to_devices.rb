class AddDevToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :is_dev, :boolean
  end
end
