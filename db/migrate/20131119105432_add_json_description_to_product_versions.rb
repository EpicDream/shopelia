class AddJsonDescriptionToProductVersions < ActiveRecord::Migration
  def change
    add_column :product_versions, :json_description, :text
  end
end