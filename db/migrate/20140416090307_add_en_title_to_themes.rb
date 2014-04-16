class AddEnTitleToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :en_title, :text
    add_column :themes, :en_subtitle, :text
  end
end