class RefactorCollectionItems < ActiveRecord::Migration
  def  change
    rename_column :collection_items, :product_version_id, :product_id
  end
end
