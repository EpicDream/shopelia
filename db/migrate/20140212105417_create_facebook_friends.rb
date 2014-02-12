class CreateFacebookFriends < ActiveRecord::Migration
  def change
    create_table :facebook_friends do |t|
      t.references :flinker #facebook friend of this flinker
      t.integer :friend_flinker_id, :default => nil #if is a flinker too
      t.string :identifier
      t.string :name
      t.string :picture
      t.timestamps
    end
    add_index :facebook_friends, :flinker_id
    add_index :facebook_friends, :friend_flinker_id
  end
end
