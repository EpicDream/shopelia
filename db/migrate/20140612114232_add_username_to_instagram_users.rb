class AddUsernameToInstagramUsers < ActiveRecord::Migration
  def change
    add_column :instagram_users, :username, :string
    add_column :instagram_users, :full_name, :string
  end
end