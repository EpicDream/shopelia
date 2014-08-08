class CreateApnsNotifications < ActiveRecord::Migration
  def change
    create_table :apns_notifications, :force => true do |t|
      t.text :text_en
      t.text :text_fr
      t.timestamps
    end
  end
end