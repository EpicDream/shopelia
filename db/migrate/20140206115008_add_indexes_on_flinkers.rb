class AddIndexesOnFlinkers < ActiveRecord::Migration
  def up
    add_index :flinkers, [:is_publisher, :staff_pick]
    add_index :flinkers, :country_id
  end

  def down
    remove_index :flinkers, [:is_publisher, :staff_pick]
    remove_index :flinkers, :country_id
  end
end