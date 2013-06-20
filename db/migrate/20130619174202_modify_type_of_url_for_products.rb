class ModifyTypeOfUrlForProducts < ActiveRecord::Migration
  def up
    change_column :products, :url, :text
  end

  def down
    change_column :products, :url, :string
  end
end
