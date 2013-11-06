class AddImageSizeToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :image_size, :string
  end
end
