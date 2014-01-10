class SetUrlOfImagesOfTypeText < ActiveRecord::Migration
  def up
    change_column :images, :url, :text
  end

  def down
    change_column :images, :url, :string
  end
end
