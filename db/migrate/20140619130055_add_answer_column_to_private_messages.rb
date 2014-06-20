class AddAnswerColumnToPrivateMessages < ActiveRecord::Migration
  def change
    add_column :private_messages, :answer, :boolean, default:false
  end
end