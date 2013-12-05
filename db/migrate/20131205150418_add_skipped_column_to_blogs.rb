class AddSkippedColumnToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :skipped, :boolean, default:false
  end
end