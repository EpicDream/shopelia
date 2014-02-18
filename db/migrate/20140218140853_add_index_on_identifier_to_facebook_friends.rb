class AddIndexOnIdentifierToFacebookFriends < ActiveRecord::Migration
  def change
    add_index :facebook_friends, :identifier
  end
end
