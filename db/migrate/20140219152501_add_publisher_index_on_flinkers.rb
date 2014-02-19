class AddPublisherIndexOnFlinkers < ActiveRecord::Migration
  def up
    remove_index :flinkers, [:is_publisher, :staff_pick]
    add_index :flinkers, [:is_publisher, :looks_count]
  end

  def down
    add_index :flinkers, [:is_publisher, :staff_pick]
    remove_index :flinkers, [:is_publisher, :looks_count]
  end
end
