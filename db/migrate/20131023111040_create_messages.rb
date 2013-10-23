class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.text :data
      t.boolean :from_admin
      t.boolean :pending_answer
      t.boolean :read
      t.timestamps
    end
  end
end
