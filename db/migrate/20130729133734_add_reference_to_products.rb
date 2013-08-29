class AddReferenceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :reference, :string
    add_column :product_versions, :reference, :string
    add_column :product_versions, :images, :text
  end
end
