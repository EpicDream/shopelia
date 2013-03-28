class AddInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :civility, :integer
    add_column :users, :birthdate, :datetime
  end
end
