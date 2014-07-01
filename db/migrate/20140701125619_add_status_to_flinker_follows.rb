class AddStatusToFlinkerFollows < ActiveRecord::Migration
  def change
    add_column :flinker_follows, :on, :boolean, default: true
    add_index :flinker_follows, :on
  end
end