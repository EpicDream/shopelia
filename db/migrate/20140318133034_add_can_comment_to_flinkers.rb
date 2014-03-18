class AddCanCommentToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :can_comment, :boolean, :default => true
  end
end