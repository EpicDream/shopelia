class AddEmailIndexToFlinkers < ActiveRecord::Migration
  def change
    add_index :flinkers, :email,                :unique => true
  end
end
