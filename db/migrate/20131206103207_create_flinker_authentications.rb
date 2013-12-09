class CreateFlinkerAuthentications < ActiveRecord::Migration
  def change
    create_table :flinker_authentications do |t|
      t.string :flinker_id
      t.string :provider
      t.string :uid
      t.string :token
      t.timestamps
    end
  end
end
