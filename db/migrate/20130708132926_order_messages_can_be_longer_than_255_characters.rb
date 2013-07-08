class OrderMessagesCanBeLongerThan255Characters < ActiveRecord::Migration
  def up
    change_column :orders, :message, :text
  end

  def down
    change_column :orders, :message, :string
  end
end
