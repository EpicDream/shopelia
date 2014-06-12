class CreateInstagramFriendships < ActiveRecord::Migration
  def change
    create_table :instagram_friendships, :force => true, :id => false do |t|
      t.integer :instagram_user_id, :null => false
      t.integer :instagram_target_id, :null => false
    end
    add_index :instagram_friendships, :instagram_user_id
    add_index :instagram_friendships, :instagram_target_id
  end
end