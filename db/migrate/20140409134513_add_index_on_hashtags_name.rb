class AddIndexOnHashtagsName < ActiveRecord::Migration
  def change
    add_index :hashtags, :name
  end
end