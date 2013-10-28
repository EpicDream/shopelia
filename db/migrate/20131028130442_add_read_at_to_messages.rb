class AddReadAtToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :read_at, :timestamp
    remove_column :messages, :read
  end
end
