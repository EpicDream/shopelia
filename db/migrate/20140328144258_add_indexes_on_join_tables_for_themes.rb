class AddIndexesOnJoinTablesForThemes < ActiveRecord::Migration
  def change
    add_index :hashtags_themes, [:hashtag_id, :theme_id ]
    add_index :countries_themes, [:country_id, :theme_id ]
  end
end
