class AddColumnForStiToFlinkerAuthentications < ActiveRecord::Migration
  def up
    add_column :flinker_authentications, :type, :string
    add_index :flinker_authentications, :type
    FlinkerAuthentication.where(provider: "facebook").update_all(type: "FacebookAuthentication")
  end
  
  def down
    remove_column :flinker_authentications, :type
  end
end