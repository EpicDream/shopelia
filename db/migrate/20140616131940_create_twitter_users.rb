class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users, :force => true do |t|
      t.references :flinker
      t.string :twitter_id
      t.string :access_token
      t.string :access_token_secret
      t.string :username
      t.timestamps
    end
    add_index :twitter_users, :flinker_id
    add_index :twitter_users, :twitter_id
  end
end
