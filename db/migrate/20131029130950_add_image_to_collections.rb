class AddImageToCollections < ActiveRecord::Migration
  def change
    add_attachment :collections, :image
    add_column :collections, :public, :boolean, :default => false
  end
end
