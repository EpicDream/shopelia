class AddUsernameToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :username, :string
  end
end
