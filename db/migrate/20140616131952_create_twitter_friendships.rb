class CreateTwitterFriendships < ActiveRecord::Migration
  def change
    create_table :twitter_friendships, :force => true, :id => false do |t|
      t.integer :twitter_user_id, :null => false
      t.integer :twitter_target_id, :null => false
    end
    add_index :twitter_friendships, :twitter_user_id
    add_index :twitter_friendships, :twitter_target_id
  end
end
