class AddLastRevivalAtToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :last_revival_at, :datetime
  end
end