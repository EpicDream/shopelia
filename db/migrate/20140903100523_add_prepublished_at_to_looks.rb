class AddPrepublishedAtToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :prepublished_at, :datetime
  end
end