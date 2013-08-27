class RemoveUserIdFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :user_id
  end

  def down
    add_column :events, :user_id, :integer
  end
end
