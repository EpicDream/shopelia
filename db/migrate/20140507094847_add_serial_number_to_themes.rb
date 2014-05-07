class AddSerialNumberToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :series, :integer, default:0
  end
end