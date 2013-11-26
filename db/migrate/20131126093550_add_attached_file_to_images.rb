class AddAttachedFileToImages < ActiveRecord::Migration
  def self.up
    add_attachment :images, :picture
    add_column :images, :picture_fingerprint, :string
    add_column :images, :picture_size, :string
  end

  def self.down
    remove_attachment :images, :picture
    remove_column :images, :picture_fingerprint
    remove_column :images, :picture_size
  end
end
