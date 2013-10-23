class AddPropertiesToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :push_token, :string
    add_column :devices, :os, :string
    add_column :devices, :os_version, :string
    add_column :devices, :phone, :string
    add_column :devices, :referrer, :string
    add_column :devices, :build, :integer
    add_column :devices, :version, :string
  end
end
