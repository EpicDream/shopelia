class RemoveHighlightedToHashtags < ActiveRecord::Migration
  def change
    remove_column :hashtags, :highlighted
  end
end