class CreatePspUsers < ActiveRecord::Migration
  def change
    create_table :psp_users do |t|
      t.integer :user_id
      t.integer :psp_id
      t.integer :remote_user_id

      t.timestamps
    end
  end
end
