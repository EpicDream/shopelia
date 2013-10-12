class CreateTableCollectionsProductVersions < ActiveRecord::Migration
  def up
    create_table :collections_product_versions, :id => false do |t|
      t.integer :collection_id
      t.integer :product_version_id
    end
  end

  def down
    drop_table :collections_product_versions
  end
end
