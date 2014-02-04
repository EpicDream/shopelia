class CreateLookSharings < ActiveRecord::Migration
  def change
    create_table :look_sharings do |t|
      t.references :look
      t.references :flinker
      t.references :social_network
      t.timestamps
    end
    add_index :look_sharings, :look_id
  end
end