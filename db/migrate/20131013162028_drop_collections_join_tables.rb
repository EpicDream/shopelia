class DropCollectionsJoinTables < ActiveRecord::Migration
  def up
    drop_table :collections_product_versions
    drop_table :collections_tags
  end

  def down
  end
end
