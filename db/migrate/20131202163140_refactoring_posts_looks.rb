class RefactoringPostsLooks < ActiveRecord::Migration
  def change
    remove_column :looks, :post_id, :integer
    remove_column :posts, :status, :string
  end
end
