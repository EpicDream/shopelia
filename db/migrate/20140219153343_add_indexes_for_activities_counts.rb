class AddIndexesForActivitiesCounts < ActiveRecord::Migration
  def change
    add_index :flinker_likes, :flinker_id
    add_index :looks, :flinker_id
  end
end