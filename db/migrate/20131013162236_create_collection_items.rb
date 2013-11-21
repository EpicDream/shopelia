class CreateCollectionItems < ActiveRecord::Migration
  def change
    create_table :collection_items do |t|
      t.integer :collection_id
      t.integer :product_version_id
      t.integer :user_id

      t.timestamps
    end
  end
end
