class CreateTableCollectionsTags < ActiveRecord::Migration
  def up
    create_table :collections_tags, :id => false do |t|
      t.integer :collection_id
      t.integer :tag_id
    end
  end

  def down
    drop_table :collections_tags
  end
end
