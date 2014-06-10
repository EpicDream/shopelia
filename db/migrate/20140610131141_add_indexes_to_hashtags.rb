class AddIndexesToHashtags < ActiveRecord::Migration
  def change
    add_index :hashtags, :highlighted
  end
end