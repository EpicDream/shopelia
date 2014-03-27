class AddCoverHeightAttributeToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :cover_height, :integer, default:100
  end
end