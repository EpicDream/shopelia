class CreateFlinkerLikes < ActiveRecord::Migration
  def change
    create_table :flinker_likes do |t|
      t.integer :flinker_id
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end

    add_index :flinker_likes, [:flinker_id, :resource_type, :resource_id], :name => "index_flinker_likes_on_all_fields"
    add_index :flinker_likes, [:resource_type, :resource_id]
  end
end
