class AddUniqIndexOnJoinTables < ActiveRecord::Migration
  def change
    add_index :looks_themes, [:look_id, :theme_id ], :unique => true
    add_index :flinkers_themes, [:flinker_id, :theme_id ], :unique => true
  end
end