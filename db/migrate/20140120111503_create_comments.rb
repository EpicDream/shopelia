class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.references :look
      t.references :flinker

      t.timestamps
    end
    add_index :comments, :look_id
    add_index :comments, :flinker_id
  end
end
