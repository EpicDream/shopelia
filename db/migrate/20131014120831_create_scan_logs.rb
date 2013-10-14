class CreateScanLogs < ActiveRecord::Migration
  def change
    create_table :scan_logs do |t|
      t.string :ean
      t.integer :device_id
      t.integer :prices_count

      t.timestamps
    end
  end
end
