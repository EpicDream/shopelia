class AddUsernameFieldToFacebookFriends < ActiveRecord::Migration
  def change
    add_column :facebook_friends, :username, :string
  end
end