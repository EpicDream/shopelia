class AddPositionToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :position, :integer
  end
end