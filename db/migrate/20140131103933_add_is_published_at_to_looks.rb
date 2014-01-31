class AddIsPublishedAtToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :is_published_updated_at, :datetime, :default => nil
  end
end