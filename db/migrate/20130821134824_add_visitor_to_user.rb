class AddVisitorToUser < ActiveRecord::Migration
  def change
    add_column :users, :visitor, :boolean, :default => false
  end
end
