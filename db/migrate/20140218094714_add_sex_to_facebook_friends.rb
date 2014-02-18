class AddSexToFacebookFriends < ActiveRecord::Migration
  def change
    add_column :facebook_friends, :sex, :string
  end
end