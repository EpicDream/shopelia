class AddStatusToFlinkerLikes < ActiveRecord::Migration
  def change
    add_column :flinker_likes, :on, :boolean, default:true
    add_index :flinker_likes, :on
  end
end