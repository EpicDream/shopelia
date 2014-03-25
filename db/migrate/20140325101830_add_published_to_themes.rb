class AddPublishedToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :published, :boolean, default:false
  end
end