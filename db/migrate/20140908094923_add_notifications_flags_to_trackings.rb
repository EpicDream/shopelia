class AddNotificationsFlagsToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :notification_id, :integer
    add_column :trackings, :notif_opened, :boolean
  end
end