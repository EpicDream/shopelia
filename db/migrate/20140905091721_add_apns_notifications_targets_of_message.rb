class AddApnsNotificationsTargetsOfMessage < ActiveRecord::Migration
  def change
    add_column :apns_notifications, :resource_id, :integer
    add_column :apns_notifications, :resource_klass_name, :string, default:nil
    add_column :apns_notifications, :resource_identifier, :string, default:nil
  end
end