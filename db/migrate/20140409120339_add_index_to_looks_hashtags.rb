class AddIndexToLooksHashtags < ActiveRecord::Migration
  def change
    add_index :hashtags_looks,  [:look_id, :hashtag_id]
  end
end