class RenameLooksIsPublishedUpdatedAt < ActiveRecord::Migration
  def change
    rename_column :looks, :is_published_updated_at, :flink_published_at
  end
end