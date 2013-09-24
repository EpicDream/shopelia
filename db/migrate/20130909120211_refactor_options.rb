class RefactorOptions < ActiveRecord::Migration
  def change
    rename_column :product_versions, :size, :option1
    rename_column :product_versions, :color, :option2
    add_column :product_versions, :option3, :text
    add_column :product_versions, :option4, :text
    add_column :product_versions, :option1_md5, :string
    add_column :product_versions, :option2_md5, :string
    add_column :product_versions, :option3_md5, :string
    add_column :product_versions, :option4_md5, :string
  end
end
