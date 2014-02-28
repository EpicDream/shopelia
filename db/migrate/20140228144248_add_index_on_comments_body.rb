class AddIndexOnCommentsBody < ActiveRecord::Migration
  def change
    add_index :comments, :body
  end
end