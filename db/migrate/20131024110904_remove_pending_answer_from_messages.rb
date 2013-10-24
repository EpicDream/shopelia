class RemovePendingAnswerFromMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :pending_answer
  end

  def down
    add_column :messages, :pending_answer, :boolean
  end
end
