class AddUuidToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :uuid, :string
    add_index :flinkers, :uuid
  end
end