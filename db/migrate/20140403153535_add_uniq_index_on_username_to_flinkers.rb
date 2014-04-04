class AddUniqIndexOnUsernameToFlinkers < ActiveRecord::Migration
  def change
    remove_index :flinkers, :username
    add_index :flinkers, :username, uniq:true
  end
end