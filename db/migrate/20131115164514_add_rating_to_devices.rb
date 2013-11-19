class AddRatingToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :rating, :integer
    add_column :messages, :rating, :integer
  end
end
