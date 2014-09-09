class AddPreprodFlagToInAppNotifications < ActiveRecord::Migration
  def change
    add_column :in_app_notifications, :preproduction, :boolean, default:false
    add_index :in_app_notifications, :preproduction
  end
end