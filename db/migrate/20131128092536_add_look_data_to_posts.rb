class AddLookDataToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :look_id, :integer
    add_column :posts, :status, :string
    add_column :posts, :processed_at, :datetime
  end
end
