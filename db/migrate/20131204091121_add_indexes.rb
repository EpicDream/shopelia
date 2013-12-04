class AddIndexes < ActiveRecord::Migration
  def change
    add_index :images, [:resource_id, :type]
    add_index :look_products, :look_id
    add_index :looks, :is_published
    add_index :looks, :uuid
  end
end
