class AddIsPublisherToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :is_publisher, :boolean, :default => false
  end
end
