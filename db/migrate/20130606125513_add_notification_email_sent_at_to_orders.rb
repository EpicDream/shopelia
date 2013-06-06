class AddNotificationEmailSentAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :notification_email_sent_at, :datetime
  end
end
