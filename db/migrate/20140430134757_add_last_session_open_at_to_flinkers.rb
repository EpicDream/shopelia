class AddLastSessionOpenAtToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :last_session_open_at, :datetime
  end
end