class AddCanCommentToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :can_comment, :boolean, default:false
  end
end