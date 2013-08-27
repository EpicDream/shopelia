class AddTrackerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tracker, :string
  end
end
