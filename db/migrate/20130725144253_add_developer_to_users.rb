class AddDeveloperToUsers < ActiveRecord::Migration
  def change
    add_column :users, :developer_id, :integer
    User.all.each do |user|
      user.update_column "developer_id", 1
    end
  end
end
