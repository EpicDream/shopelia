class AddImageSizeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :image_size, :string
  end
end
