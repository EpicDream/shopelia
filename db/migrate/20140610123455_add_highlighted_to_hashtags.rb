class AddHighlightedToHashtags < ActiveRecord::Migration
  def change
    add_column :hashtags, :highlighted, :boolean, default:false
  end
end