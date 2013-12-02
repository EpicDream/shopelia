class AddFlinkerIdToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :flinker_id, :integer
  end
end
