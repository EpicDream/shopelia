class AddIndexesToHighlightedLooks < ActiveRecord::Migration
  def change
    add_index :highlighted_looks, :look_id
    add_index :highlighted_looks, :hashtag_id
  end
end