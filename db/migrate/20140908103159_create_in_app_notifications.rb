class CreateInAppNotifications < ActiveRecord::Migration
  def change
    create_table :in_app_notifications, :force => true do |t|
      t.string :lang
      t.string :title
      t.integer :resource_id
      t.string :resource_klass_name
      t.string :resource_identifier
      t.references :image
      t.string :min_build
      t.datetime :expire_at
      t.timestamps
    end
    add_index :in_app_notifications, :lang
    add_index :in_app_notifications, :min_build
    add_index :in_app_notifications, :expire_at
  end
end