class AddIndexOnUsernameToFlinkers < ActiveRecord::Migration
  def change
    add_index :flinkers, :username
  end
end
