class AddAutorepliedToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :autoreplied, :boolean, :default => false
  end
end
