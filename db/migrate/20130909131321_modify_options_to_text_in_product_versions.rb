class ModifyOptionsToTextInProductVersions < ActiveRecord::Migration
  def up
    change_column :product_versions, :option1, :text
    change_column :product_versions, :option2, :text
  end

  def down
    change_column :product_versions, :option1, :string
    change_column :product_versions, :option2, :string
  end
end
