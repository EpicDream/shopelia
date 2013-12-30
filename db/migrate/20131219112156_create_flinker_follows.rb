class CreateFlinkerFollows < ActiveRecord::Migration
  def change
    create_table :flinker_follows do |t|
      t.integer :flinker_id
      t.integer :follow_id

      t.timestamps
    end

    add_index :flinker_follows, :flinker_id
    add_index :flinker_follows, :follow_id
  end
end
