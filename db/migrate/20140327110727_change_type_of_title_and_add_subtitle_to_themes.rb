class ChangeTypeOfTitleAndAddSubtitleToThemes < ActiveRecord::Migration
  def change
    change_column :themes, :title, :text
    add_column :themes, :subtitle, :text
  end
end