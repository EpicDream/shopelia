class CreateRevivalLogs < ActiveRecord::Migration
  def change
    create_table :revival_logs, :force => true do |t|
      t.integer :count
      t.timestamps
    end
  end
end