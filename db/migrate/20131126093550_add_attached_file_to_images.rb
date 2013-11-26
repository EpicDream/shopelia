class AddAttachedFileToImages < ActiveRecord::Migration
  def self.up
    add_attachment :images, :picture
    add_column :images, :picture_fingerprint, :string
    add_column :images, :picture_sizes, :string #sizes of images stocked as json
  end

  def self.down
    remove_attachment :images, :picture
    remove_column :images, :picture_fingerprint
    remove_column :images, :picture_sizes
  end
end
