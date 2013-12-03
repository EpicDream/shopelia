class RefactoringPostsLooks < ActiveRecord::Migration
  def change
    remove_column :looks, :post_id
    remove_column :posts, :status
  end
end
