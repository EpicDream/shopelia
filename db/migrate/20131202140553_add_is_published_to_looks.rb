class AddIsPublishedToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :is_published, :boolean, :default => false
  end
end
