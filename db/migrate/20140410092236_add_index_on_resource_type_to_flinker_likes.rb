class AddIndexOnResourceTypeToFlinkerLikes < ActiveRecord::Migration
  def change
    add_index :flinker_likes, :resource_type
  end
end