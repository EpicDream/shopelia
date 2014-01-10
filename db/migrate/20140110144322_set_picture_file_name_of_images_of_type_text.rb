class SetPictureFileNameOfImagesOfTypeText < ActiveRecord::Migration
  def up
    change_column :images, :picture_file_name, :text
  end

  def down
    change_column :images, :picture_file_name, :string
  end
end
