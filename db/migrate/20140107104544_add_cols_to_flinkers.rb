class AddColsToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :staff_pick, :boolean, :default => false
    add_column :flinkers, :looks_count, :integer, :default => 0
    add_column :flinkers, :follows_count, :integer, :default => 0
    add_column :flinkers, :likes_count, :integer, :default => 0
  end
end
