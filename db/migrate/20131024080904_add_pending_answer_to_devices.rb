class AddPendingAnswerToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :pending_answer, :boolean
  end
end
